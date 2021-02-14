import ezsheets
import os
import shutil
os.chdir('../credentials')

s = ezsheets.Spreadsheet('https://docs.google.com/spreadsheets/d/1zSTBdbVN1kR3sU40ydkIbG00QPgrnKdXm-ZMa0CcBr0/edit#gid=141178862')
s.downloadAsExcel()

## Convert to xml
os.system('xls2xform passivemalariasurveillance.xlsx passivemalariasurveillance.xml ')

# Move
shutil.move('passivemalariasurveillance.xlsx', '../forms/passivemalariasurveillance/passivemalariasurveillance.xlsx')
shutil.move('passivemalariasurveillance.xml',  '../forms/passivemalariasurveillance/passivemalariasurveillance.xml')
shutil.move('itemsets.csv', '../forms/passivemalariasurveillance/itemsets.csv')

print('Done. Docs in forms/passivemalariasurveillance.')
