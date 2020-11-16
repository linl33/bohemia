#!/usr/bin/python

def corrections_dict_data():
    ''' 
    Function to track all the corrections to be applied in the database. 
    To add entries, manually edit this file and commit to repo via PR process/
    To read the entries, call this function from the code you need the data at.
    
    Every correction entry in the dict should follow this format.
    
    corrections_dict = {
        'corrections_id': {
            'resolution_category': '',
            'resolution_action': '',
            'resolution_steps': '', # Leave blank if a preset_correction_steps exists in the database for this
            'resolution_values': [], # Ensure these are ordered in the way they should be replaced in the SQL statement(s).
        }
    }
    '''

    corrections_dict = {
        # "dd8b625d-d1bb-45e8-b37a-829d284cf809": {
        #     "resolution_category": "strange_wid",
        #     "resolution_action": "strange_wid_update",
        #     "resolution_steps": "",
        #     "resolution_values": ["375", "dd8b625d-d1bb-45e8-b37a-829d284cf809"],
        # },
        # "69675dbc-34f1-40ca-a1e7-5f56c2d20a8f": {
        #     "resolution_category": "strange_wid",
        #     "resolution_action": "strange_wid_update",
        #     "resolution_steps": "",
        #     "resolution_values": ["325", "69675dbc-34f1-40ca-a1e7-5f56c2d20a8f"],
        # },
        # "cd74f2d4-bde8-4a25-8ad4-2294a841237f": {
        #     "resolution_category": "strange_wid",
        #     "resolution_action": "strange_wid_confirmed_ok",
        #     "resolution_steps": "SELECT * FROM temp_minicensus_main WHERE instance_id = %s;",
        #     "resolution_values": ["cd74f2d4-bde8-4a25-8ad4-2294a841237f"]
        # }
    }

    return corrections_dict
