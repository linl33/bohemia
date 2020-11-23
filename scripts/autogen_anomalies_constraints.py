import pandas as pd 
import ezsheets
import os

def get_anomalies_constraints(creds_dir = '../credentials', gbook_url ='https://docs.google.com/spreadsheets/d/1r9v4lJHvMYxMZpwdwdlb6nkTe9cQrpLlHEmfJbQ4kjw/edit#gid=141178862', gsheet_name='smallcensusb'):
    """
    This function parses a given xls worksheet to copy the anomalies and warnings defined in it.

    Args:
        creds_dir: String indicating location of credentials folder
        gbook_url: String indicating the url to the google sheets workbook. 
        gsheet_name: [Optional] String indicating the label for the worksheet to be parsed.

    Returns:
        Pandas dataframe 
    """
    this_dir = os.getcwd()
    os.chdir(creds_dir)
    s = ezsheets.Spreadsheet(gbook_url)
    s.downloadAsExcel()
    x = pd.read_excel(gsheet_name + '.xlsx')
    os.chdir(this_dir)
    xlsdata = x

    tbl = []
    for idx, entry in xlsdata.iterrows():
        tblrow = {'row': idx}
        if type(entry['constraint']) != float:
            tblrow.update({
                'constraint': entry['constraint'], 
                'constraint_message::English': entry['constraint_message::English'],
                'constraint_message::Swahili': entry['constraint_message::Swahili'],
                'constraint_message::Portuguese': entry['constraint_message::Portuguese'],
                'constraint_condition': entry['calculation']
            })
        if entry['type'] == 'note':
            tblrow.update({
                'warning_name': entry['name'],
                'warning_label::English': entry['label::English'],
                'warning_label::Swahili': entry['label::Swahili'],
                'warning_label::Portuguese': entry['label::Portuguese'],
                'warning_hint::English': entry['hint::English'],
                'warning_hint::Swahili': entry['hint::Swahili']
                })
        if len(tblrow) > 1:
            tbl.append(tblrow)

    return pd.DataFrame(tbl)


if __name__ == "__main__":
    data = get_anomalies_constraints(creds_dir = '../credentials', gbook_url = 'https://docs.google.com/spreadsheets/d/1r9v4lJHvMYxMZpwdwdlb6nkTe9cQrpLlHEmfJbQ4kjw/edit#gid=141178862', gsheet_name='smallcensusb')
    data.to_csv('/tmp/done.csv')
