import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1KaJVsiBvf3gpmp3-4t-M9Ro58rzQX5SSAyZ-DLNQ5Vs/edit#gid=141178862')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform varefusals.xlsx varefusals.xml ')

# Move
shutil.move('varefusals.xlsx', '../forms/varefusals/varefusals.xlsx')
shutil.move('varefusals.xml',  '../forms/varefusals/varefusals.xml')
shutil.move('itemsets.csv', '../forms/varefusals/itemsets.csv')

print('Done. Docs in forms/varefusals.')
