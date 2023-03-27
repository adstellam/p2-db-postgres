import json
import csv
from argparse import ArgumentParser
from pathlib import Path

parser = ArgumentParser()
parser.add_argument('jsonfile')
args = parser.parse_args()

with open(args.jsonfile) as ifs:
    data = json.load(ifs)
    
csvfile = Path(args.jsonfile).with_suffix('.csv')

with open(csvfile, 'w', newline='') as ofs:
    csv_writer = csv.writer(ofs)
    header = ['plant_id', 'commondity_type', 'diameter_cm', 'wet_date', 'measure_date', 'irregular', 'position']
    csv_writer.writerow(header)
    for feature in data['features']:
        prop = feature['properties']
        geom = feature['geometry']
        row = []
        row.append(prop['id'])
        row.append(prop['commodity_type'])
        row.append(prop['diameter_cm'])
        row.extend([prop['wet_date'], prop['measure_date']])
        row.append(prop['irregular'])
        row.append((geom['coordinates'][0], geom['coordinates'][1]))
        csv_writer.writerow(row)
