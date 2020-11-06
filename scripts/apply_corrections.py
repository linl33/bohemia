#!/usr/bin/python
import psycopg2
import pandas as pd
import logging

# Set up log file for job
logging.basicConfig(filename="logs/apply_corrections.log", level=logging.DEBUG)

# Initialize connection to the database
dbconn = psycopg2.connect(dbname="bohemia", user="bohemia_app", password="")
cur = dbconn.cursor()

# NOTE: Make sure to run this once only then comment out the code to prevent duplicated entries
preset_corrections_dict = {
    "strange_hh_code": {
        "strange_hh_code_update_code_hamlet_only": "UPDATE clean_minicensus_main SET hh_hamlet_code = %s, hh_hamlet = %s WHERE instance_id = %s;",
        "strange_hh_code_update_code_hamlet_village": "UPDATE clean_minicensus_main SET hh_hamlet_code = %s, hh_hamlet = %s, hh_village = %s WHERE instance_id = %s;",
        "strange_hh_code_update_code_hamlet_village_ward": "UPDATE clean_minicensus_main SET hh_hamlet_code = %s, hh_hamlet = %s , hh_village = %s, hh_ward = %s WHERE instance_id = %s;",
        "strange_hh_code_update_code_hamlet_hhid": "UPDATE clean_minicensus_main SET hh_hamlet_code = %s, hh_hamlet = %s, hh_id = %s WHERE instance_id = %s;",
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
        cur.execute(
            """
            INSERT INTO preset_correction_steps (created_by, status, resolution_category, resolution_action, correction_steps)
            VALUES (%s, %s, %s, %s, %s);
            """,
            ("script", "active", key, action, query),
        )

dbconn.commit()

# read excel or csv file
xlsheets = ["alert1", "alert2", "VA_IDmiss", "alert4"]
file_path = "tmp/fixes_20201031_for_Databrew_updated.xlsx"

for sheet in xlsheets:
    logging.debug(f"Reading sheet {sheet}\n")
    df = pd.read_excel(file_path, sheet_name=sheet)

    correction_steps_values = {
        "strange_hh_code_update_code_hamlet_only": [
            "fix_alert4a",
            "fix_alert4b",
            "instance_id",
        ],
        "strange_hh_code_update_code_hamlet_village": [
            "fix_alert4a",
            "fix_alert4b",
            "fix_alert4d",
            "instance_id",
        ],
        "strange_hh_code_update_code_hamlet_village_ward": [
            "fix_alert4a",
            "fix_alert4b",
            "fix_alert4d",
            "fix_alert4e",
            "instance_id",
        ],
        "strange_hh_code_update_code_hamlet_hhid": [
            "fix_alert4a",
            "fix_alert4b",
            "fix_alert4c",
            "instance_id",
        ],
        "no_va_id_update": ["fix_VA_IDmiss", "instance_id"],
        "missing_wid_update": ["fix_alert2", "instance_id"],
        "strange_wid_update": ["fix_alert1", "instance_id"],
    }

    # for each row, extract anomaly_id, instance_id, resolution_category, resolution_action, data in alerts* column
    for idx, entry in df.iterrows():
        try:
            anomaly_id = entry["id"]
            resp_detail = entry["responsedetails"]
            resolved_by = entry["resolvedby"]
            res_date = entry["resolutiondate"]
            res_method = entry["resolutionmethod"]
            submitted_at = "2020-10-31"
            resolution_category = entry["resolution_category"]
            resolution_action = entry["resolution_action"]
            instance_id = entry["instance_id"]

            logging.debug(f"Correction in progress for anomaly : {anomaly_id}")
            cur.execute(
                """
                INSERT INTO corrections (instance_id, anomaly_id, response_details, resolved_by, resolution_date, resolution_method, submitted_by, submitted_at, resolution_category, resolution_action)
                VALUES (%(instance_id)s, %(anomaly_id)s, %(resp_detail)s, %(resolved_by)s, %(res_date)s, %(res_method)s, %(submitted_by)s, %(submitted_at)s, %(res_category)s, %(res_action)s) RETURNING id;
                """,
                {
                    "resp_detail": resp_detail,
                    "resolved_by": resolved_by,
                    "res_date": res_date,
                    "res_method": res_method,
                    "submitted_by": resolved_by,
                    "submitted_at": submitted_at,
                    "res_category": resolution_category,
                    "res_action": resolution_action,
                    "instance_id": instance_id,
                    "anomaly_id": anomaly_id,
                },
            )

            correction_id = cur.fetchone()[0]
            logging.debug(f"Correction entry created: {correction_id}")

            cur.execute(
                """
                SELECT id, correction_steps 
                FROM preset_correction_steps 
                WHERE resolution_category = %s 
                AND resolution_action = %s 
                AND status = 'active';
                """,
                (
                    resolution_category,
                    resolution_action,
                ),
            )

            preset_entry = cur.fetchone()
            preset_steps_id, correction_steps = preset_entry[0], preset_entry[1]
            logging.debug(f"Preset correction steps retrieved: {preset_entry}")

            correct_data = correction_steps_values.get(resolution_action)
            corrections = [entry[x] for x in correct_data]
            corrections = tuple(corrections)
            statement = f"{correction_steps} % {corrections}"

            logging.debug(f"Applying correction step: {statement}\n")
            cur.execute(correction_steps, corrections)

            logging.debug(f"Updating corrections to Done")
            cur.execute(
                """
                UPDATE corrections SET done = TRUE, done_by = 'pyscript' WHERE id = %(correction_id)s;
                """,
                {
                    "correction_id": correction_id,
                },
            )

            logging.debug(f"Creating log table entry")
            cur.execute(
                """
                INSERT INTO anomaly_corrections_log (anomaly_id, correction_id, preset_steps_id, user_id, log_detail)
                VALUES (%(anomaly_id)s, %(correction_id)s, %(preset_correction_steps_id)s, %(user_email)s, %(statement)s)
                RETURNING id;
                """,
                {
                    "anomaly_id": anomaly_id,
                    "correction_id": correction_id,
                    "preset_correction_steps_id": preset_steps_id,
                    "user_email": "pyscript",
                    "statement": statement,
                },
            )
            log_id = cur.fetchone()[0]
            logging.debug(
                f"Correction action successfully logged: {log_id}\nCommitting transaction\n\n"
            )
            dbconn.commit()
        except Exception as e:
            logging.exception(f"Exception raised: {e} \n")
            dbconn.rollback()
            continue

cur.close()
dbconn.close()
