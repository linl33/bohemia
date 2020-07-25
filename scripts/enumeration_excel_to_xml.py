import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1rPBLjrto66gAmbJSYc_H-I-ymkbnYPCprAzrpmGwKF4/edit#gid=0')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform enumerations.xlsx enumerations.xml ')

# Move
shutil.move('enumerations.xlsx', '../forms/enumerations/enumerations.xlsx')
shutil.move('enumerations.xml',  '../forms/enumerations/enumerations.xml')

print('Done. Docs in forms/enumerations.')
