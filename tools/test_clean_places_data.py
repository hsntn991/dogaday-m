import csv
import tempfile
import unittest
from pathlib import Path

from clean_places_data import clean_and_link


class CleanPlacesDataTests(unittest.TestCase):
    def test_keeps_only_supported_types_and_links_nearby_child_to_national_park(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'places_rows.csv'
            main_output = root / 'main.csv'
            amenities_output = root / 'amenities.csv'
            source.write_text(
                '\n'.join([
                    'id,name,subtype,latitude,longitude,city,district',
                    '10,Yedigoller,national_park,40.9000,31.8000,Bolu,Merkez',
                    '11,Camp A,camp_site,40.9500,31.8000,Bolu,Merkez',
                    '12,Uzak Selale,waterfall,41.5000,31.8000,Bolu,Merkez',
                    '13,Cesme,water_fountain,40.9010,31.8010,Bolu,Merkez',
                    '14,Tepe,mountain,40.9020,31.8020,Bolu,Merkez',
                    '15,Orman,nature_park,40.8500,31.8000,Bolu,Merkez',
                ]),
                encoding='utf-8',
            )

            report = clean_and_link(source, main_output, amenities_output)

            with main_output.open(encoding='utf-8-sig', newline='') as handle:
                main_rows = list(csv.DictReader(handle))
            with amenities_output.open(encoding='utf-8-sig', newline='') as handle:
                amenity_rows = list(csv.DictReader(handle))

            self.assertEqual(report['main_rows'], 4)
            self.assertEqual(report['amenity_rows'], 1)
            self.assertEqual(report['discarded_rows'], 1)
            self.assertEqual(
                {row['clean_type'] for row in main_rows},
                {'national_park', 'camp', 'waterfall'},
            )
            self.assertEqual(
                next(row for row in main_rows if row['id'] == '11')['parent_id'],
                '10',
            )
            self.assertEqual(
                next(row for row in main_rows if row['id'] == '12')['parent_id'],
                '',
            )
            self.assertEqual(amenity_rows[0]['subtype'], 'water_fountain')


if __name__ == '__main__':
    unittest.main()
