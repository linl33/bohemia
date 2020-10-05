import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1sf3vtqBjWnFfJpUSMiTLDj-o2d23mYb_fMUwMmurgQY/edit#gid=0')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform geocoding.xlsx geocoding.xml ')

# Move
shutil.move('geocoding.xlsx', '../forms/geocoding/geocoding.xlsx')
shutil.move('geocoding.xml',  '../forms/geocoding/geocoding.xml')
# shutil.move('itemsets.csv', '../forms/geocoding/itemsets.csv')

print('Done. Docs in forms/geocoding.')
