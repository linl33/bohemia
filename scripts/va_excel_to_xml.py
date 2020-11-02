import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1xq6nr65Rm5prK5C-vWkVJFvzCodoXGY7TJrAHxGGWZ4/edit#gid=1264701015')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform va153.xlsx va153.xml')

# Move
shutil.move('va153.xlsx', '../forms/va153/va153.xlsx')
shutil.move('va153.xml',  '../forms/va153/va153.xml')
shutil.move('itemsets.csv', '../forms/va153/itemsets.csv')

print('Done. Docs in forms/va.')
