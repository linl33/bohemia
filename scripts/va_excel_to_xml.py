import pygsheets
import xlrd
import os
#import numpy as np

# Authorize by using this: https://pygsheets.readthedocs.io/en/latest/authorization.html
gc = pygsheets.authorize('../credentials/gsheets_oauth.json')

doc = 'who_va_odk'
sh = gc.open(doc)
wks = sh.sheet1

#export as xls
wks.export(pygsheets.ExportType.XLS, doc)

## Convert to xml
os.system('xls2xform ' + doc + '.xls ' + doc +'.xml')

print("Successfully created the following documents:\n---" + doc + '.xls\n---' + doc +'.xml')
