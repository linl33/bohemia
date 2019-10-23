import pygsheets
import xlrd
import os
#import numpy as np

# Authorize by using this: https://pygsheets.readthedocs.io/en/latest/authorization.html
gc = pygsheets.authorize('../credentials/gsheets_oauth.json')

# Open spreadsheet and then workseet
sh = gc.open('censusopenhds')
wks = sh.sheet1

#export as xls
wks.export(pygsheets.ExportType.XLS, 'censusopenhds')

## Convert to xml
os.system('xls2xform censusopenhds.xls censusopenhds.xml')
