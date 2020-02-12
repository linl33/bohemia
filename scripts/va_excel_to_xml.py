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

os.rename(doc + '.xls' ,'va.xls')


## Convert to xml
os.system('xls2xform ' + 'va' + '.xls ' + 'va' +'.xml')

# Move
shutil.move('va.xls', "../forms/va/va.xls")
shutil.move('va.xml', "../forms/va/va.xml")

print("Successfully created the following documents:\n---" + 'va' + '.xls\n---' + 'va' +'.xml')
