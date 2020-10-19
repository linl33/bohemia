import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1r9v4lJHvMYxMZpwdwdlb6nkTe9cQrpLlHEmfJbQ4kjw/edit?usp=sharing')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform smallcensusa.xlsx smallcensusa.xml ')

# Move
shutil.move('smallcensusa.xlsx', '../forms/smallcensusa/smallcensusa.xlsx')
shutil.move('smallcensusa.xml',  '../forms/smallcensusa/smallcensusa.xml')
shutil.move('itemsets.csv', '../forms/smallcensusa/itemsets.csv')

print('Done. Docs in forms/smallcensusa.')
