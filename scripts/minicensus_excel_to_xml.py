import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1r9v4lJHvMYxMZpwdwdlb6nkTe9cQrpLlHEmfJbQ4kjw/edit?usp=sharing')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform minicensus.xlsx minicensus.xml ')

# Move
shutil.move('minicensus.xlsx', '../forms/minicensus/minicensus.xlsx')
shutil.move('minicensus.xml',  '../forms/minicensus/minicensus.xml')
shutil.move('itemsets.csv', '../forms/minicensus/itemsets.csv')

print('Done. Docs in forms/minicensus.')
