"""Clean Doğadayım place rows and assign nearby parent parks.

The input file is never changed.  It creates separate CSV files for visible
nature places and for small amenities such as drinking water and toilets.
"""

from __future__ import annotations

import argparse
import csv
import math
from collections import Counter
from pathlib import Path
from typing import Iterable


AMENITY_TYPES = {'drinking_water', 'water_fountain', 'toilet'}
DISCARDED_TYPES = {'mountain', 'hill', 'peak', 'plateau', 'plateau_landform'}
TYPE_MAP = {
    'camp_site': 'camp',
    'caravan_site': 'caravan',
    'lake': 'lake',
    'waterfall': 'waterfall',
    'canyon': 'canyon_valley',
    'valley': 'canyon_valley',
    'cave': 'cave',
    'national_park': 'national_park',
    'nature_park': 'national_park',
}
PARENTABLE_TYPES = {'camp', 'caravan', 'lake', 'waterfall', 'canyon_valley', 'cave'}
MAIN_FIELDS = ['id', 'name', 'clean_type', 'latitude', 'longitude', 'city', 'district', 'parent_id']
AMENITY_FIELDS = ['id', 'name', 'subtype', 'latitude', 'longitude', 'city', 'district']


def _normalized_city(value: str) -> str:
    return (
        (value or '').strip().casefold()
        .replace('ı', 'i')
        .replace('ş', 's')
        .replace('ğ', 'g')
        .replace('ü', 'u')
        .replace('ö', 'o')
        .replace('ç', 'c')
    )


def haversine_km(first_lat: float, first_lon: float, second_lat: float, second_lon: float) -> float:
    """Return the great-circle distance between two coordinates in kilometres."""
    radius_km = 6371.0088
    lat_delta = math.radians(second_lat - first_lat)
    lon_delta = math.radians(second_lon - first_lon)
    a = (
        math.sin(lat_delta / 2) ** 2
        + math.cos(math.radians(first_lat))
        * math.cos(math.radians(second_lat))
        * math.sin(lon_delta / 2) ** 2
    )
    return 2 * radius_km * math.asin(math.sqrt(a))


def _valid_coordinate(row: dict[str, str]) -> bool:
    try:
        latitude = float(row['latitude'])
        longitude = float(row['longitude'])
    except (KeyError, TypeError, ValueError):
        return False
    return -90 <= latitude <= 90 and -180 <= longitude <= 180


def _read_rows(path: Path) -> Iterable[dict[str, str]]:
    with path.open(encoding='utf-8-sig', newline='') as handle:
        yield from csv.DictReader(handle)


def _write_rows(path: Path, fields: list[str], rows: Iterable[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8-sig', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, extrasaction='ignore')
        writer.writeheader()
        writer.writerows(rows)


def clean_and_link(
    source_path: Path | str,
    main_output_path: Path | str,
    amenities_output_path: Path | str,
    *,
    parent_radius_km: float = 15,
) -> dict[str, object]:
    """Split source rows, map public types and attach nearby national parks."""
    source = Path(source_path)
    main_rows: list[dict[str, str]] = []
    amenity_rows: list[dict[str, str]] = []
    discarded = Counter()
    invalid_rows = 0

    for raw in _read_rows(source):
        subtype = (raw.get('subtype') or '').strip().lower()
        supplied_clean_type = (raw.get('clean_type') or '').strip().lower()
        if not raw.get('id', '').strip() or not raw.get('name', '').strip() or not _valid_coordinate(raw):
            invalid_rows += 1
            continue
        base = {field: (raw.get(field) or '').strip() for field in AMENITY_FIELDS}
        if subtype in AMENITY_TYPES:
            amenity_rows.append(base)
            continue
        clean_type = (
            supplied_clean_type
            if supplied_clean_type in set(TYPE_MAP.values())
            else TYPE_MAP.get(subtype)
        )
        if clean_type is None:
            discarded[subtype or supplied_clean_type or 'missing_subtype'] += 1
            continue
        main_rows.append({
            **base,
            'clean_type': clean_type,
            'parent_id': '',
        })

    parks_by_city: dict[str, list[dict[str, str]]] = {}
    for row in main_rows:
        if row['clean_type'] == 'national_park':
            parks_by_city.setdefault(_normalized_city(row['city']), []).append(row)

    linked_children = 0
    for row in main_rows:
        if row['clean_type'] not in PARENTABLE_TYPES:
            continue
        closest_parent: dict[str, str] | None = None
        closest_distance = parent_radius_km
        for park in parks_by_city.get(_normalized_city(row['city']), []):
            distance = haversine_km(
                float(row['latitude']), float(row['longitude']),
                float(park['latitude']), float(park['longitude']),
            )
            if distance <= closest_distance:
                closest_parent = park
                closest_distance = distance
        if closest_parent is not None:
            row['parent_id'] = closest_parent['id']
            linked_children += 1

    _write_rows(Path(main_output_path), MAIN_FIELDS, main_rows)
    _write_rows(Path(amenities_output_path), AMENITY_FIELDS, amenity_rows)
    return {
        'main_rows': len(main_rows),
        'amenity_rows': len(amenity_rows),
        'discarded_rows': sum(discarded.values()),
        'discarded_by_subtype': dict(sorted(discarded.items())),
        'invalid_rows': invalid_rows,
        'linked_children': linked_children,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description='Clean Doğadayım place data safely.')
    parser.add_argument('source', type=Path, help='Original places_rows.csv path')
    parser.add_argument('--places-out', type=Path, required=True)
    parser.add_argument('--amenities-out', type=Path, required=True)
    parser.add_argument('--parent-radius-km', type=float, default=15)
    args = parser.parse_args()
    report = clean_and_link(
        args.source,
        args.places_out,
        args.amenities_out,
        parent_radius_km=args.parent_radius_km,
    )
    print(report)


if __name__ == '__main__':
    main()
