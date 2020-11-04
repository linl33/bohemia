import ezsheets
import os
import shutil
os.chdir('../credentials')

# Read in main sheet
s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1xq6nr65Rm5prK5C-vWkVJFvzCodoXGY7TJrAHxGGWZ4/edit#gid=1264701015')
s.downloadAsExcel()

# Read in locations
import pandas as pd

df = pd.read_csv('https://raw.githubusercontent.com/databrew/bohemia/master/forms/locations.csv')
df.to_csv('locations.csv', index=False)

## Convert to xml
os.system('xls2xform va153.xlsx va153.xml')

# Move
shutil.move('va153.xlsx', '../forms/va153/va153.xlsx')
shutil.move('va153.xml',  '../forms/va153/va153.xml')
shutil.move('itemsets.csv', '../forms/va153/itemsets.csv')
shutil.move('locations.csv', '../forms/va153/locations.csv')

# Zip
os.chdir('../forms/va153/')
if os.path.exists('metadata'):
    shutil.rmtree('metadata')
os.mkdir('metadata')
shutil.move('itemsets.csv', 'metadata/itemsets.csv')
shutil.move('locations.csv', 'metadata/locations.csv')
shutil.make_archive('metadata', 'zip', 'metadata')
if os.path.exists('metadata'):
    shutil.rmtree('metadata')

print('Done. Careful, the locations.csv came from github, not the xls')
