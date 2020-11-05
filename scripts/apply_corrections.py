#!/usr/bin/python
import pyscopg2
import pandas as pd

# Initialize connection to the database
dbconn = pyscopg2.connect("dbname=bohemia user=bohemia_app")
cur = dbconn.cursor()

preset_corrections_dict = {
    "strange_hh_code": {
        "strange_hh_code_update_code_hamlet_only": "UPDATE clean_minicensus_main SET hh_hamlet_code = %s, hh_hamlet = %s WHERE instance_id = %s;",
        "strange_hh_code_update_code_hamlet_village": "UPDATE clean_minicensus_main SET hh_hamlet_code = %s, hh_hamlet = %s, hh_village = %s WHERE instance_id = %s;",
        "strange_hh_code_update_code_hamlet_village_ward": "UPDATE clean_minicensus_main SET hh_hamlet_code = %s, hh_hamlet = %s , hh_village = %s, hh_ward = %s WHERE instance_id = %s;",
        "strange_hh_code_update_code_hamlet_hhid": "UPDATE clean_minicensus_main SET hh_hamlet_code = %s, hh_hamlet = %s, hh_id = %s WHERE instance_id = %s;"
    },
    "no_va_id": {
        "no_va_id_update": "UPDATE clean_va SET death_id = %s WHERE instance_id = %s;",
    },
    "missing_wid": {
        "missing_wid_update": "UPDATE clean_minicensus_main SET wid = %s WHERE instance_id = %s;",
    },
    "strange_wid": {
        "strange_wid_update": "UPDATE clean_minicensus_main SET wid = %s WHERE instance_id = %s;"
    },
}

for key, values in preset_corrections_dict.items():
    for action, query in values.items():
        cur.execute("""
        INSERT INTO preset_correction_steps (created_by, status, resolution_category, resolution_action, correction_steps)
        VALUES (%s, %s, %s, %s, %s);""", ('script', 'active', key, action, query))

dbconn.commit()

# read excel or csv file
file_path = '/tmp/fixes_20201031_for_Databrew.xlsx'
df = pd.read_excel(file_path)

# for each row, extract anomaly_id, instance_id, resolution_category, resolution_action, data in alerts* column
for entry in df:
    anomaly_id = entry['id']
    resp_detail = entry['responsedetails']
    resolved_by = entry['resolvedby']
    res_date = entry['resolutiondate']
    res_method = entry['resolutionmethod']
    submitted_at = "2020-10-31"
    resolution_category = entry['resolution_category']
    resolution_action = entry['resolution_action']
    instance_id = entry['instance_id']
    
    cur.execute("""
        INSERT INTO corrections (anomaly_id, response_details, resolved_by, resolution_date, resolution_method, submitted_by, submitted_at, resolution_category, resolution_action)
        VALUES (%(anomaly_id)s, %(resp_detail)s, %(resolved_by)s, %(res_date)s, %(res_method)s, %(submitted_by)s, %(submitted_at)s, %(res_category)s, %(res_action)s);
        """, {'anomaly_id': anomaly_id, 
              'resp_detail': response_details, 
              'resolved_by': resolved_by, 
              'res_date': res_date,
              'res_method': resolution_method, 
              'submitted_by': resolved_by,
              'submitted_at': submitted_at,
              'res_category': resolution_category,
              'res_action': resolution_action,
              })

    cur.execute("""SELECT correction_steps 
                                      FROM preset_correction_steps 
                                      WHERE resolution_category = %s 
                                      AND resolution_action = %s 
                                      AND status = 'active';
                                   """, (resolution_category, resolution_action,)
    )

    correction_steps = cur.fetchone()[0]

    stmt = f"{correction_steps},{entry['fix_alert1']}"

    cur.execute("""
        UPDATE corrections SET done = TRUE, done_by = 'pyscript' WHERE anomaly_id = %(anomaly_id)s;
        """, {'anomaly_id': anomaly_id, 
    })


    cur.execute("""
        INSERT INTO anomaly_corrections_log (anomaly_id, correction_id, preset_steps_id, user_id, log_details)
        VALUES (%(anomaly_id)s, %(correction_id)s, %(preset_correction_steps_id)s, %(user_email)s, %(statement)s);
        """, {'anomaly_id': anomaly_id, 
              'correction_id': correction_id, 
              'preset_correction_steps_id': preset_correction_steps_id, 
              'user_email': user_email,
              'statement': statement, 
              })

dbconn.commit()

cur.close()
dbconn.close()

 