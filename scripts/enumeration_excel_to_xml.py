import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1rPBLjrto66gAmbJSYc_H-I-ymkbnYPCprAzrpmGwKF4/edit#gid=0')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform enumerationsb.xlsx enumerationsb.xml ')

# Move
shutil.move('enumerationsb.xlsx', '../forms/enumerationsb/enumerationsb.xlsx')
shutil.move('enumerationsb.xml',  '../forms/enumerationsb/enumerationsb.xml')

print('Done. Docs in forms/enumerationsb.')
