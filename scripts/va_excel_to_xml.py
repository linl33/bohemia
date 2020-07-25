import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1BuRSJdWmottUW8SDnh8nGTkLCeTjEX3LgkRpaPvoKjE/edit#gid=1264701015')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform va.xlsx va.xml ')

# Move
shutil.move('va.xlsx', '../forms/va/va.xlsx')
shutil.move('va.xml',  '../forms/va/va.xml')

print('Done. Docs in forms/va.')
