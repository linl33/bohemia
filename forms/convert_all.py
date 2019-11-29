import os
files = [i for i in os.listdir("xlsx") if i.endswith("xls")]

for file in files:
    from_path = 'xlsx/' + file
    to_path = 'xml/' + file.replace('.xls', '.xml')
    this_text = 'From: ' + from_path + ' To: ' + to_path
    convert_text = 'xls2xform ' + from_path + ' ' + to_path
    os.system(convert_text)
