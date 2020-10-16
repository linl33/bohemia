import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1umclN03WeV5Q4GAlBGDXvbOTG_VKKMFECu-STfyyWSE/edit#gid=141178862')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform xingx.xlsx xingx.xml ')

# Move
shutil.move('xingx.xlsx', '../forms/xingx/xingx.xlsx')
shutil.move('xingx.xml',  '../forms/xingx/xingx.xml')
shutil.move('itemsets.csv', '../forms/xingx/itemsets.csv')

print('Done. Docs in forms/xingx.')
