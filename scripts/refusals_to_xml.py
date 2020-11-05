import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1CqKEzs0tiIMnwd7_mjrPLICme3eSOTYu66DByrEOpbw/edit#gid=1607361427')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform refusalsb.xlsx refusalsb.xml ')

# Move
shutil.move('refusalsb.xlsx', '../forms/refusalsb/refusalsb.xlsx')
shutil.move('refusalsb.xml',  '../forms/refusalsb/refusalsb.xml')
shutil.move('itemsets.csv', '../forms/refusalsb/itemsets.csv')

print('Done. Docs in forms/refusals.')
