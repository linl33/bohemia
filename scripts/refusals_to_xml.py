import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1CqKEzs0tiIMnwd7_mjrPLICme3eSOTYu66DByrEOpbw/edit#gid=1607361427')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform refusals.xlsx refusals.xml ')

# Move
shutil.move('refusals.xlsx', '../forms/refusals/refusals.xlsx')
shutil.move('refusals.xml',  '../forms/refusals/refusals.xml')
shutil.move('itemsets.csv', '../forms/refusals/itemsets.csv')

print('Done. Docs in forms/refusals.')
