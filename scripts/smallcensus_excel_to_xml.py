import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1r9v4lJHvMYxMZpwdwdlb6nkTe9cQrpLlHEmfJbQ4kjw/edit?usp=sharing')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform smallcensusa.xlsx smallcensus.xml ')

# Move
shutil.move('smallcensusa.xlsx', '../forms/smallcensus/smallcensus.xlsx')
shutil.move('smallcensus.xml',  '../forms/smallcensus/smallcensus.xml')
shutil.move('itemsets.csv', '../forms/smallcensus/itemsets.csv')

print('Done. Docs in forms/smallcensus.')
