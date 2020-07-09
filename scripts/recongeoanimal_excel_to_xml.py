import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1APsFS5BrXDu5v1jrZ4EwyOGcos4JVxV61DDe9x-HKQA/edit#gid=619584240')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform recongeoanimal.xlsx recongeoanimal.xml ')

# Move
shutil.move('recongeoanimal.xlsx', '../forms/recongeoanimal/recongeoanimal.xlsx')
shutil.move('recongeoanimal.xml',  '../forms/recongeoanimal/recongeoanimal.xml')
shutil.move('itemsets.csv', '../forms/recongeoanimal/itemsets.csv')

print('Done. Docs in forms/recongeoanimal.')
