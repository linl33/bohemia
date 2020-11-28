import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1i3mzVjV-Ynu_3MbG_ovzWOHdYK-EuP0_q1SR-W1lJ8U/edit#gid=0')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform census.xlsx census.xml ')

# Move
shutil.move('census.xlsx', '../forms/census/census.xlsx')
shutil.move('census.xml',  '../forms/census/census.xml')
shutil.move('itemsets.csv', '../forms/census/itemsets.csv')

print('Done. Docs in forms/census.')
