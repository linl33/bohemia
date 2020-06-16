import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/16_drw-35haLaBlB6tn92mr6zbIuYorAUDyieGONyGTM/edit#gid=141178862')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform census.xlsx census.xml ')

# Move
shutil.move('census.xlsx', '../forms/census/census.xlsx')
shutil.move('census.xml',  '../forms/census/census.xml')
shutil.move('itemsets.csv', '../forms/census/itemsets.csv')

print('Done. Docs in forms/census.')
