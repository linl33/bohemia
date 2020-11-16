#!/usr/bin/python
import psycopg2
import logging
import os
import yaml
from correction_data_detail import corrections_dict_data

# Set up log file for job
project_root = "/home/ubuntu/Documents/bohemia/"
filepath = os.path.join(project_root, 'logs', 'process_corrections.log')
logging.basicConfig(filename=filepath, level=logging.DEBUG)

# Initialize connection to the database
with open(os.path.join(project_root, "credentials", "credentials.yaml")) as cfile:
    creds = yaml.safe_load(cfile)

dbconn = psycopg2.connect(
    dbname="bohemia", 
    user=creds['psql_dev_username'], 
    password=creds["psql_dev_password"], 
    host=creds["psql_dev_endpoint"]
)
cur = dbconn.cursor()


def process_corrections():
    '''
    Function that reads the `corrections` table for entries that are not 'done' and 
    updates them to done iff there exists `corrections_dict_data` for the entry.
    '''

    cur.execute("""SELECT * FROM corrections WHERE done != TRUE;""")
    pending_corrections = cur.fetchall()
    
    for correction_id, availed_correction in corrections_dict_data().items():
        if correction_id in pending_corrections: # TODO: Refactor to make id, resolution_columns and anomaly_id separate vars
            try:
                cur.execute(
                    """
                    SELECT id, correction_steps 
                    FROM preset_correction_steps 
                    WHERE resolution_category = %s 
                    AND resolution_action = %s 
                    AND status = 'active';
                    """,
                    (
                        availed_correction.get('resolution_category'),
                        availed_correction.get('resolution_action'),
                    ),
                )

                preset_entry = cur.fetchone()
                preset_steps_id, correction_steps = preset_entry[0], preset_entry[1]
                logging.debug(f"Preset correction steps retrieved: {preset_entry}")

                corrections_data = availed_correction.get('resolution_values')
                corrections_data = tuple(corrections_data)
                statement = f"{correction_steps} % {corrections_data}"

                logging.debug(f"Applying correction step: {statement}\n")
                cur.execute(correction_steps, corrections_data)

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
                if availed_correction.get('resolution_steps') is not None:
                    correction_steps = availed_correction.get('resolution_steps')
                    corrections_data = availed_correction.get('resolution_values')
                    corrections_data = tuple(corrections_data)
                    statement = f"{correction_steps} % {corrections_data}"

                    logging.debug(f"Applying correction step: {statement}\n")
                    cur.execute(correction_steps, corrections_data)

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
                else:
                    logging.exception(f"Exception raised: {e} \n")
                    dbconn.rollback()
                    continue

    cur.close()
    dbconn.close()

if __name__ == "__main__":
    process_corrections()