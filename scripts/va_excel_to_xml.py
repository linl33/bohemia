import ezsheets
import os
import shutil
os.chdir('../credentials')

# Read in main sheet
s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1xq6nr65Rm5prK5C-vWkVJFvzCodoXGY7TJrAHxGGWZ4/edit#gid=1264701015')
s.downloadAsExcel()

# Read in locations
import pandas as pd

d = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=640399777')
d.downloadAsCSV('locations.csv')


## Convert to xml
os.system('xls2xform va153b.xlsx va153b.xml')

# Move
shutil.move('va153b.xlsx', '../forms/va153b/va153b.xlsx')
shutil.move('va153b.xml',  '../forms/va153b/va153b.xml')
shutil.move('itemsets.csv', '../forms/va153b/itemsets.csv')
shutil.move('locations.csv', '../forms/va153b/locations.csv')

# Zip
os.chdir('../forms/va153b/')
if os.path.exists('metadata'):
    shutil.rmtree('metadata')
os.mkdir('metadata')
shutil.move('itemsets.csv', 'metadata/itemsets.csv')
shutil.move('locations.csv', 'metadata/locations.csv')
shutil.make_archive('metadata', 'zip', 'metadata')
if os.path.exists('metadata'):
    shutil.rmtree('metadata')

print('Done. Careful, the locations.csv came from github, not the xls')
