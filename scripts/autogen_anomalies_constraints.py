import pygsheets
import pandas as pd 


def get_anomalies_constraints(creds_file: str, gbook_url: str, gsheet_name='survey'):
    """
    This function parses a given xls worksheet to copy the anomalies and warnings defined in it.

    Args:
        creds_file: String indicating the path to the json credentials file.
        gbook_url: String indicating the url to the google sheets workbook. 
        gsheet_name: [Optional] String indicating the label for the worksheet to be parsed.

    Returns:
        Pandas dataframe 
    """

    # Authorize by using this: https://pygsheets.readthedocs.io/en/latest/authorization.html
    gc = pygsheets.authorize(creds_file)

    workbook = gc.open_by_url(gbook_url)
    worksheet = workbook.get_worksheet(gsheet_name)

    xlsdata = worksheet.get_all_values()

    tbl = []
    # xlsdata = pd.read_excel('/home/katekimani/projects/databrew/bohemia/tmp/smallcensusb.xlsx') TODO: Delete once PR is approved
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
    # creds_file='/home/katekimani/projects/databrew/bohemia/credentials/gsheets_oauth.json' TODO: Delete once PR is approved
    # gbook_url='https://docs.google.com/spreadsheets/d/1WkY4iOUU-cI4cepMOiBu16wPnXG3yRSOTyp3_9K-zLo/edit#gid=141178862' TODO: Delete once PR is approved
    data = get_anomalies_constraints(creds_file, gbook_url)