import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1APsFS5BrXDu5v1jrZ4EwyOGcos4JVxV61DDe9x-HKQA/edit#gid=619584240')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform animalannex.xlsx animalannex.xml ')

# Move
shutil.move('animalannex.xlsx', '../forms/animalannex/animalannex.xlsx')
shutil.move('animalannex.xml',  '../forms/animalannex/animalannex.xml')
shutil.move('itemsets.csv', '../forms/animalannex/itemsets.csv')

print('Done. Docs in forms/animalannex.')
