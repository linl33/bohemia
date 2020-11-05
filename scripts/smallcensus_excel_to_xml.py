import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1r9v4lJHvMYxMZpwdwdlb6nkTe9cQrpLlHEmfJbQ4kjw/edit?usp=sharing')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform smallcensusb.xlsx smallcensusb.xml ')

# Move
shutil.move('smallcensusb.xlsx', '../forms/smallcensusb/smallcensusb.xlsx')
shutil.move('smallcensusb.xml',  '../forms/smallcensusb/smallcensusb.xml')
shutil.move('itemsets.csv', '../forms/smallcensusb/itemsets.csv')

print('Done. Docs in forms/smallcensusa.')
