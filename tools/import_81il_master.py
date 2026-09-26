"""Import the reviewed Doğadayım 81 il master workbook into Supabase.

The import is intentionally conservative: it keeps the workbook's taxonomy,
does not claim that generic water is potable, and publishes records as
community-verified rather than silently presenting them as editorially verified.
Run with --dry-run first. The token is read from DOGADAYIM_IMPORT_TOKEN.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.request
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from openpyxl import load_workbook


PROJECT_REF = "lluypcdjiuyskelbwxys"
API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"
DEFAULT_WORKBOOK = Path(r"C:\Users\CASPER\Desktop\Dogadayim_81IL_MASTER_V9_DUZELTILMIS_ISIMLER.xlsx")
SHEET_NAME = "Doğadayım Master (13.940)"
# Two management-API calls are made per batch; 240 keeps the full import under
# the API's standard per-minute project rate limit while retaining small payloads.
BATCH_SIZE = 240

SUBTYPE_TO_TAXONOMY = {
    "lake": ("Göl", "water"),
    "waterfall": ("Şelale", "water"),
    "stream": ("Su Kaynağı", "water"),
    "river": ("Su Kaynağı", "water"),
    "spring": ("Su Kaynağı", "water"),
    "mountain": ("Yayla", "mountain_terrain"),
    "peak": ("Yayla", "mountain_terrain"),
    "hill": ("Yayla", "mountain_terrain"),
    "plateau": ("Yayla", "mountain_terrain"),
    "plateau_landform": ("Yayla", "mountain_terrain"),
    "valley": ("Yayla", "mountain_terrain"),
    "canyon": ("Kanyon", "natural_formation"),
    "cave": ("Mağara", "natural_formation"),
    "sinkhole": ("Mağara", "natural_formation"),
    "travertine": ("Kanyon", "natural_formation"),
    "fairy_chimney": ("Kanyon", "natural_formation"),
    "forest": ("Milli Park", "nature_area"),
    "national_park": ("Milli Park", "nature_area"),
    "nature_park": ("Tabiat Parkı", "nature_area"),
    "wetland": ("Milli Park", "nature_area"),
    "protected_area": ("Milli Park", "nature_area"),
    "picnic_area": ("Piknik Alanı", "nature_area"),
    "camp_site": ("Kamp Alanı", "camp_caravan"),
    "caravan_site": ("Karavan Alanı", "camp_caravan"),
    "hiking": ("Yürüyüş Rotası", "route_activity"),
    "cycling": ("Yürüyüş Rotası", "route_activity"),
    "viewpoint": ("Seyir Noktası", "discovery_point"),
    "sunset_viewpoint": ("Seyir Noktası", "discovery_point"),
    "birdwatching": ("Milli Park", "wildlife"),
    "monument_tree": ("Milli Park", "wildlife"),
    "toilet": ("WC", None),
    "drinking_water": ("İçme Suyu", None),
}


def clean(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def sql_text(value: str | None) -> str:
    if value is None:
        return "NULL"
    return "'" + value.replace("'", "''") + "'"


def sql_bool(value: bool | None) -> str:
    return "NULL::boolean" if value is None else ("TRUE" if value else "FALSE")


def sql_text_array(values: list[str]) -> str:
    if not values:
        return "ARRAY[]::text[]"
    return "ARRAY[" + ", ".join(sql_text(v) for v in values) + "]::text[]"


def stable_slug(name: str, latitude: float, longitude: float) -> str:
    normalized = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    normalized = re.sub(r"[^a-z0-9]+", "-", normalized.lower()).strip("-")[:58]
    fingerprint = hashlib.sha1(f"{name}|{latitude:.6f}|{longitude:.6f}".encode()).hexdigest()[:12]
    return f"v9-{normalized or 'dogadayim'}-{fingerprint}"


@dataclass(frozen=True)
class PlaceRow:
    name: str
    city: str
    district: str | None
    address: str | None
    latitude: float
    longitude: float
    category_name: str
    main_category: str | None
    subtype: str
    short_description: str | None
    description: str | None
    alternate_names: list[str]
    slug: str
    facilities: dict[str, bool | None]


def facility_values(row: dict[str, Any], subtype: str) -> dict[str, bool | None]:
    water = clean(row.get("Su_var_mi_Google")) or ""
    toilet = clean(row.get("WC_var_mi_Google")) or ""
    fire = clean(row.get("Ates_Yakma_Durumu_Valilik")) or ""
    result: dict[str, bool | None] = {}

    if toilet.startswith("Var"):
        result["toilets"] = True
    elif toilet.startswith("Yakında"):
        result["nearby_toilets"] = True
    elif toilet.startswith("Yok"):
        result["toilets"] = False

    # Water labels in this workbook are often streams, taps, or nearby water;
    # only the sheet's explicit drinking-water place subtype is marked potable.
    if subtype == "drinking_water":
        if water.startswith("Var"):
            result["drinking_water"] = True
        elif water.startswith("Yakında"):
            result["nearby_drinking_water"] = True
        elif water.startswith("Yok"):
            result["drinking_water"] = False

    # Seasonal / conditional guidance should not become a permanent yes/no claim.
    if fire.startswith("Yasak"):
        result["open_fire_allowed"] = False
    elif fire.startswith("Serbest"):
        result["open_fire_allowed"] = True

    if subtype == "caravan_site":
        result["caravans"] = True
    if subtype == "camp_site":
        result["tents"] = True
    if subtype == "picnic_area":
        result["picnic_allowed"] = True
    return result


def load_rows(workbook: Path) -> tuple[list[PlaceRow], Counter[str]]:
    book = load_workbook(workbook, read_only=True, data_only=True)
    if SHEET_NAME not in book.sheetnames:
        raise ValueError(f"Çalışma sayfası bulunamadı: {SHEET_NAME}")
    sheet = book[SHEET_NAME]
    headers = [clean(value) or "" for value in next(sheet.values)]
    required = {"Il", "Yeni_Ad_Google", "Ana_Kategori", "Alt_Tur", "Enlem", "Boylam", "App_Kategori"}
    missing = required - set(headers)
    if missing:
        raise ValueError(f"Eksik sütunlar: {', '.join(sorted(missing))}")

    rows: list[PlaceRow] = []
    seen: set[tuple[str, float, float]] = set()
    skipped = Counter()
    for values in sheet.iter_rows(min_row=2, values_only=True):
        raw = dict(zip(headers, values))
        name, city = clean(raw["Yeni_Ad_Google"]), clean(raw["Il"])
        subtype = clean(raw["Alt_Tur"])
        if not name or not city or subtype not in SUBTYPE_TO_TAXONOMY:
            skipped["missing_or_unmapped"] += 1
            continue
        try:
            latitude, longitude = float(raw["Enlem"]), float(raw["Boylam"])
        except (TypeError, ValueError):
            skipped["invalid_coordinates"] += 1
            continue
        if not (-90 <= latitude <= 90 and -180 <= longitude <= 180):
            skipped["out_of_range_coordinates"] += 1
            continue
        key = (name.casefold(), round(latitude, 6), round(longitude, 6))
        if key in seen:
            skipped["workbook_duplicate"] += 1
            continue
        seen.add(key)
        category_name, main_category = SUBTYPE_TO_TAXONOMY[subtype]
        original_name = clean(raw.get("Eski_Ad_OSM"))
        short = clean(raw.get("Kisa_Bilgi_Notu_Google"))
        description = clean(raw.get("SEO_Description")) or short
        rows.append(
            PlaceRow(
                name=name,
                city=city,
                district=clean(raw.get("Ilce")),
                address=clean(raw.get("Yakin_Koy_Mahalle")),
                latitude=latitude,
                longitude=longitude,
                category_name=category_name,
                main_category=main_category,
                subtype=subtype,
                short_description=(short or description)[:500] if (short or description) else None,
                description=description,
                alternate_names=[original_name] if original_name and original_name.casefold() != name.casefold() else [],
                slug=stable_slug(name, latitude, longitude),
                facilities=facility_values(raw, subtype),
            )
        )
    return rows, skipped


def query(token: str, sql: str) -> list[dict[str, Any]]:
    request = urllib.request.Request(
        API_URL,
        # The Management API defaults some token contexts to a read-only
        # transaction unless this is explicitly disabled. This importer needs
        # one writable transaction for its insert and facility upsert batches.
        data=json.dumps({"query": sql, "read_only": False}).encode(),
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as error:
        detail = error.read().decode(errors="replace")
        raise RuntimeError(f"Supabase sorgusu başarısız ({error.code}): {detail}") from error


def get_category_ids(token: str) -> dict[str, int]:
    categories = query(token, "select id, name from public.categories order by id")
    result = {item["name"]: int(item["id"]) for item in categories}
    required = {category for category, _ in SUBTYPE_TO_TAXONOMY.values()}
    missing = required - result.keys()
    if missing:
        raise RuntimeError(f"Supabase'de gerekli kategoriler eksik: {', '.join(sorted(missing))}")
    return result


def place_values(row: PlaceRow, category_id: int) -> str:
    return "(" + ", ".join(
        [
            str(category_id), sql_text(row.name), sql_text(row.slug), sql_text(row.short_description),
            sql_text(row.description), sql_text(row.city), sql_text(row.district), sql_text(row.address),
            f"{row.latitude:.7f}", f"{row.longitude:.7f}", "TRUE", "TRUE",
            sql_text(row.main_category), sql_text(row.subtype), sql_text(row.name),
            sql_text_array(row.alternate_names), sql_text("community"), sql_text("publish"),
            "ARRAY[]::text[]",
        ]
    ) + ")"


def import_batch(token: str, rows: list[PlaceRow], category_ids: dict[str, int]) -> tuple[int, int]:
    values = ",\n".join(place_values(row, category_ids[row.category_name]) for row in rows)
    slugs = ", ".join(sql_text(row.slug) for row in rows)
    insert_sql = f"""
      WITH input(category_id, name, slug, short_description, description, city, district, address, latitude, longitude,
                 is_verified, is_active, main_category, subtype, name_tr, alternate_names, verification_level,
                 publish_status, review_reasons) AS (VALUES {values}),
      inserted AS (
        INSERT INTO public.places (category_id, name, slug, short_description, description, city, district, address,
          latitude, longitude, is_verified, is_active, main_category, subtype, name_tr, alternate_names,
          verification_level, publish_status, review_reasons)
        SELECT i.* FROM input i
        WHERE NOT EXISTS (
          SELECT 1 FROM public.places p
          WHERE lower(p.name) = lower(i.name)
            AND abs(p.latitude - i.latitude) < 0.000001
            AND abs(p.longitude - i.longitude) < 0.000001
        )
        ON CONFLICT (slug) DO NOTHING
        RETURNING id, slug
      )
      SELECT (SELECT count(*) FROM inserted) AS inserted,
             (SELECT count(*) FROM public.places WHERE slug IN ({slugs})) AS present;
    """
    outcome = query(token, insert_sql)[0]

    facility_rows = [row for row in rows if row.facilities]
    if facility_rows:
        fields = [
            "toilets", "drinking_water", "parking", "shower", "electricity", "picnic_allowed",
            "picnic_facility", "picnic_table_nearby", "bbq_allowed", "bbq_facility", "open_fire_allowed",
            "firepit_facility", "tents", "caravans", "dump_station", "nearby_toilets",
            "nearby_toilets_distance_m", "nearby_drinking_water", "nearby_drinking_water_distance_m",
            "nearby_parking", "nearby_parking_distance_m", "nearby_shower", "nearby_shower_distance_m",
        ]
        data = []
        for row in facility_rows:
            entries = [sql_text(row.slug)] + [
                "NULL::integer" if field.endswith("_distance_m") else sql_bool(row.facilities.get(field))
                for field in fields
            ]
            data.append("(" + ", ".join(entries) + ")")
        facility_sql = f"""
          WITH input(slug, {', '.join(fields)}) AS (VALUES {', '.join(data)})
          INSERT INTO public.place_facilities (place_id, {', '.join(fields)})
          SELECT p.id, {', '.join('i.' + field for field in fields)}
          FROM input i JOIN public.places p ON p.slug = i.slug
          ON CONFLICT (place_id) DO UPDATE SET
            {', '.join(field + ' = COALESCE(EXCLUDED.' + field + ', place_facilities.' + field + ')' for field in fields)},
            updated_at = now();
        """
        query(token, facility_sql)
    return int(outcome["inserted"]), int(outcome["present"])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workbook", type=Path, default=DEFAULT_WORKBOOK)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, help="İlk N kaydı test etmek için kullanılır.")
    args = parser.parse_args()
    if not args.workbook.exists():
        raise SystemExit(f"Excel dosyası bulunamadı: {args.workbook}")
    rows, skipped = load_rows(args.workbook)
    if args.limit is not None:
        rows = rows[:max(args.limit, 0)]
    print(f"Hazır kayıt: {len(rows)} | Atlanan: {dict(skipped)}")
    print("Kategori dağılımı:", dict(sorted(Counter(row.subtype for row in rows).items())))
    if args.dry_run:
        return 0
    token = os.environ.get("DOGADAYIM_IMPORT_TOKEN")
    if not token:
        raise SystemExit("DOGADAYIM_IMPORT_TOKEN tanımlı değil.")
    category_ids = get_category_ids(token)
    inserted = present = 0
    for index in range(0, len(rows), BATCH_SIZE):
        added, found = import_batch(token, rows[index:index + BATCH_SIZE], category_ids)
        inserted += added
        present += found
        print(f"{min(index + BATCH_SIZE, len(rows))}/{len(rows)} işlendi | yeni: {inserted} | mevcut: {present}")
        time.sleep(0.55)
    total = query(token, "select count(*)::int as count from public.places where slug like 'v9-%'")[0]["count"]
    print(f"Tamamlandı. Bu içe aktarmadan veritabanında bulunan kayıt: {total}; bu çalışmada yeni eklenen: {inserted}.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"İçe aktarma durdu: {error}", file=sys.stderr)
        raise SystemExit(1)
