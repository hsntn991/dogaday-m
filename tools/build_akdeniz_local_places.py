#!/usr/bin/env python3
"""Convert the vetted Akdeniz engine output to the app's offline place asset."""
import argparse
import json
from pathlib import Path

GENERIC_NAMES = {"piknik alanı", "kamp alanı", "camping", "bungalows"}


def convert(rows):
    records = []
    for row in rows:
        if row.get("poi_type") != "destination" or row.get("publish_status") != "publish":
            continue
        name = str(row.get("name") or row.get("name_tr") or "").strip()
        latitude, longitude = row.get("latitude"), row.get("longitude")
        if not name or name.casefold() in GENERIC_NAMES or latitude is None or longitude is None:
            continue
        category = str(row.get("category_tr") or row.get("category") or "Doğa Noktası")
        province = str(row.get("province") or "").strip()
        records.append({
            "id": str(row["id"]), "name": name, "province": province,
            "district": row.get("district"), "latitude": latitude, "longitude": longitude,
            "category": category, "main_category": row.get("main_category"),
            "subtype": row.get("subtype"),
            "description": row.get("about_text") or f"{name}, {province} sınırlarında yer alan bir {category.lower()} kaydı.",
            "source": "OpenStreetMap", "source_url": next((item.get("url") for item in row.get("sources", []) if item.get("url")), None),
        })
    return sorted(records, key=lambda item: (item["province"], item["name"]))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", default="assets/data/akdeniz_research_places.json")
    args = parser.parse_args()
    rows = json.loads(Path(args.input).read_text(encoding="utf-8"))
    records = convert(rows)
    Path(args.output).write_text(json.dumps(records, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Akdeniz offline place asset: {len(records)} kayıt")


if __name__ == "__main__":
    main()
