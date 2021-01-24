import ezsheets
import os
import shutil
os.chdir('../credentials')

# Read in main sheet
s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/14csTZBFLKUIHccww6a6CaAnw970jNhsES2dCEiq47NA/edit#gid=1264701015')
s.downloadAsExcel()

# Read in locations
import pandas as pd

# df = pd.read_csv('https://raw.githubusercontent.com/databrew/bohemia/master/forms/locations.csv')
d = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=640399777')
d.downloadAsCSV('locations.csv')

## Convert to xml
os.system('xls2xform censusmin.xlsx censusmin.xml')

# Move
shutil.move('censusmin.xlsx', '../forms/censusmin/censusmin.xlsx')
shutil.move('censusmin.xml',  '../forms/censusmin/censusmin.xml')
# shutil.move('itemsets.csv', '../forms/censusmin/itemsets.csv')
shutil.move('locations.csv', '../forms/censusmin/locations.csv')

# Zip
os.chdir('../forms/censusmin/')
if os.path.exists('metadata'):
    shutil.rmtree('metadata')
os.mkdir('metadata')
# shutil.move('itemsets.csv', 'metadata/itemsets.csv')
shutil.move('locations.csv', 'metadata/locations.csv')
shutil.make_archive('metadata', 'zip', 'metadata')
if os.path.exists('metadata'):
    shutil.rmtree('metadata')

print('Done. Careful, the locations.csv came from github, not the xls')
