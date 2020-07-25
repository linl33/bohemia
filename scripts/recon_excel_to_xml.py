import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1xe8WrTGAUsf57InDQPIQPfnKXc7FwjpHy1aZKiA-SLw/edit#gid=0')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform recon.xlsx recon.xml ')

# Move
shutil.move('recon.xlsx', '../forms/recon/recon.xlsx')
shutil.move('recon.xml',  '../forms/recon/recon.xml')
shutil.move('itemsets.csv', '../forms/recon/itemsets.csv')

print('Done. Docs in forms/recon.')
