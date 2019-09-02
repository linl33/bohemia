import pygsheets
import xlrd
import os
#import numpy as np

# Authorize by using this: https://pygsheets.readthedocs.io/en/latest/authorization.html
gc = pygsheets.authorize('../credentials/gsheets_oauth.json')

# Open spreadsheet and then workseet
sh = gc.open('census')
wks = sh.sheet1

#export as xls
wks.export(pygsheets.ExportType.XLS, 'census.xlsx')

# Convert to xml
exec(open('xls2xform.py').read())

os.system('python pyxform/xls2xform.py cenxus.xls census.xml')
