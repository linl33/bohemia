import pygsheets
import xlrd
import os
import shutil
#import numpy as np

# Authorize by using this: https://pygsheets.readthedocs.io/en/latest/authorization.html
gc = pygsheets.authorize('../credentials/gsheets_oauth.json')

# Define the documents
docs = ['crf2', 'crf3', 'crf4', 'ento', 'pklab']
for doc in docs:
    print('....' + doc)
    # Open spreadsheet and then workseet
    sh = gc.open(doc)
    wks = sh.sheet1

    #export as xls
    wks.export(pygsheets.ExportType.XLS, doc)

    ## Convert to xml
    os.system('xls2xform ' + doc + '.xls ' + doc +'.xml')

    # Move
    shutil.move(doc + '.xml', "../forms/pk/xml/" + doc + '.xml')
    shutil.move(doc + '.xls', "../forms/pk/xls/" + doc + '.xls')
    #os.remove(doc + '.xml')
    #os.remove(doc + '.xls')
