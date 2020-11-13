import psycopg2
import pandas as pd
import logging
import yaml
from sqlalchemy import create_engine
from datetime import datetime
import pandas.io.sql as pdsql
import os

# Set up log file for job
logging.basicConfig(filename="logs/apply_corrections.log", level=logging.DEBUG)

# Read in credentials
with open(r'../credentials/credentials.yaml') as file:
    creds = yaml.load(file, Loader=yaml.FullLoader)

# Define whether working locally or not
is_local = False
if is_local:
    dbconn = psycopg2.connect(dbname="bohemia") #psycopg2.connect(dbname="bohemia", user="bohemia_app", password="")
    engine_string = "postgresql:///bohemia"
else:
    dbconn = psycopg2.connect(dbname='bohemia', user = creds['psql_master_username'], password = creds['psql_master_password'], host = creds['endpoint'], port = 5432)
    engine_string = "postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}".format(
        user=creds['psql_master_username'],
        password=creds['psql_master_password'],
        host=creds['endpoint'],
        port='5432',
        database='bohemia',
    )

# Initialize connection to the database
cur = dbconn.cursor()
engine = create_engine(engine_string)
# engine.table_names()

# Read in corrections table
result = engine.execute('SELECT * FROM corrections')
corrections = pd.DataFrame(data = iter(result), columns = result.keys())

# Read in anomalies table
result = engine.execute('SELECT * FROM anomalies')
anomalies = pd.DataFrame(data = iter(result), columns = result.keys())

# Read in fixes table
result = engine.execute('SELECT * FROM fixes')
fixes = pd.DataFrame(data = iter(result), columns = result.keys())

# Keep only those which aren't already done
do_these = corrections[~corrections['id'].isin(fixes['id'])]
show_these = do_these[['id', 'response_details', 'instance_id']]
show_these.to_csv('/tmp/show_these.csv') # to help human

# Define function for implementing corrections
def implement(id, query = '', who = 'Joe Brew', cur = cur, dbconn = dbconn):
    # Implement the actual fix to the database
    try:
        print('Executing this query:\n')
        print(query)
        cur.execute(query)
    except:
        cur.execute("ROLLBACK")
        print('Problem executing:\n')
        print(query)
        return
    done_at = datetime.now()
    # State the fact that it has been fixed
    cur.execute(
        """
        INSERT INTO fixes (id, done_by, done_at, resolution_code) VALUES(%s, %s, %s, %s)
        """,
        (id, who, done_at, query)
    )
    dbconn.commit()

# Go one-by-one through "show_these" and implement changes
# show_these.iloc[5]

# MOZ
implement(id = 'strange_wid_f8b44ed0-4636-4f4a-a19d-5d40b5117ca5', query = "UPDATE clean_minicensus_main SET wid='375' WHERE instance_id='f8b44ed0-4636-4f4a-a19d-5d40b5117ca5'")
implement(id = 'strange_wid_9906d156-cc9b-4f5a-b341-b05bb819c2bf', query = "UPDATE clean_minicensus_main SET wid='325' WHERE instance_id='9906d156-cc9b-4f5a-b341-b05bb819c2bf'")
implement(id = 'strange_wid_6ffa7378-b1fe-4f39-9a96-9f14fd97704e', query = "UPDATE clean_minicensus_main SET wid='395' WHERE instance_id='6ffa7378-b1fe-4f39-9a96-9f14fd97704e'")
implement(id = 'strange_wid_dff375c4-ca51-43f3-b72b-b2baa734a0ab', query = "UPDATE clean_minicensus_main SET wid='395' WHERE instance_id='dff375c4-ca51-43f3-b72b-b2baa734a0ab'")
implement(id = 'strange_wid_6eeff804-3892-4164-8964-1cb70556fcc0', query = "UPDATE clean_minicensus_main SET wid='395' WHERE instance_id='6eeff804-3892-4164-8964-1cb70556fcc0'")
implement(id = 'strange_wid_edc83ea9-72c0-463c-a1a0-66701c7e5eb7', query = "UPDATE clean_minicensus_main SET wid='395' WHERE instance_id='edc83ea9-72c0-463c-a1a0-66701c7e5eb7'")
implement(id = 'strange_wid_5ea7c4fb-cdfe-495b-ab5c-27b612a29075', query = "UPDATE clean_minicensus_main SET wid='395' WHERE instance_id='5ea7c4fb-cdfe-495b-ab5c-27b612a29075'")
implement(id = 'strange_wid_fef5e7e7-f39f-4da9-900b-871dc40d8f75', query = "UPDATE clean_minicensus_main SET wid='341' WHERE instance_id='fef5e7e7-f39f-4da9-900b-871dc40d8f75'")
implement(id = 'strange_wid_897c9ff1-5ea3-4d14-8e0a-71fd3468b6b6', query = "UPDATE clean_minicensus_main SET wid='335' WHERE instance_id='897c9ff1-5ea3-4d14-8e0a-71fd3468b6b6'")
implement(id = 'strange_wid_f1af5fb4-d91b-4238-bd4e-c5317fd22212', query = "UPDATE clean_minicensus_main SET wid='358' WHERE instance_id='f1af5fb4-d91b-4238-bd4e-c5317fd22212'")
implement(id = 'strange_wid_ad282457-7760-4dae-8b9b-bf06456b3770', query = "UPDATE clean_minicensus_main SET wid='358' WHERE instance_id='ad282457-7760-4dae-8b9b-bf06456b3770'")
implement(id = 'strange_wid_a5dc80bf-f8c2-4e03-a31d-54d3b89dcb8d', query = "UPDATE clean_minicensus_main SET wid='412' WHERE instance_id='a5dc80bf-f8c2-4e03-a31d-54d3b89dcb8d'")
implement(id = 'strange_wid_280dcf0f-4092-4c23-9443-5e4d3df76b70', query = "UPDATE clean_minicensus_main SET wid='379' WHERE instance_id='280dcf0f-4092-4c23-9443-5e4d3df76b70'")
implement(id = 'missing_wid_3237f6fe-e9f4-4e00-9579-d05b30b84949', query = "UPDATE clean_minicensus_main SET wid='391' WHERE instance_id='3237f6fe-e9f4-4e00-9579-d05b30b84949'")
implement(id = 'missing_wid_30a980ee-e792-43f4-9cde-f33773d040b0', query = "UPDATE clean_minicensus_main SET wid='391' WHERE instance_id='30a980ee-e792-43f4-9cde-f33773d040b0'")
implement(id = 'missing_wid_e47a6122-c5db-41a1-ad78-5704142e91d8', query = "UPDATE clean_minicensus_main SET wid='391' WHERE instance_id='e47a6122-c5db-41a1-ad78-5704142e91d8'")
implement(id = 'missing_wid_8d3ac895-8af4-4d91-a4f3-82457c0db092', query = "UPDATE clean_minicensus_main SET wid='391' WHERE instance_id='8d3ac895-8af4-4d91-a4f3-82457c0db092'")
implement(id = 'missing_wid_af58be0b-d620-401f-a209-7391f1cc077e', query = "UPDATE clean_minicensus_main SET wid='393' WHERE instance_id='af58be0b-d620-401f-a209-7391f1cc077e'")
implement(id = 'missing_wid_48dc3722-659e-4dcb-abbe-89876dc459f0', query = "UPDATE clean_minicensus_main SET wid='393' WHERE instance_id='48dc3722-659e-4dcb-abbe-89876dc459f0'")
implement(id = 'missing_wid_c1ae4c30-940b-4a4d-8b24-bbc1123ee6ea', query = "UPDATE clean_minicensus_main SET wid='393' WHERE instance_id='c1ae4c30-940b-4a4d-8b24-bbc1123ee6ea'")
implement(id = 'missing_wid_d459768e-a7cf-45b2-9a7e-4622315f4841', query = "UPDATE clean_minicensus_main SET wid='393' WHERE instance_id='d459768e-a7cf-45b2-9a7e-4622315f4841'")
implement(id = 'missing_wid_dd8d758a-f813-421c-9fb5-1e02b0e18f01', query = "UPDATE clean_minicensus_main SET wid='393' WHERE instance_id='dd8d758a-f813-421c-9fb5-1e02b0e18f01'")
implement(id = 'missing_wid_0398dbf7-c9e8-490a-ad4c-c311f9748cac', query = "UPDATE clean_minicensus_main SET wid='393' WHERE instance_id='0398dbf7-c9e8-490a-ad4c-c311f9748cac'")
implement(id = 'missing_wid_987a9b8a-600f-41ea-a1e4-9bb7b796711f', query = "UPDATE clean_minicensus_main SET wid='393' WHERE instance_id='987a9b8a-600f-41ea-a1e4-9bb7b796711f'")
implement(id = 'missing_wid_52faeb2d-f0a7-4569-a440-3634a695245f', query = "UPDATE clean_minicensus_main SET wid='393' WHERE instance_id='52faeb2d-f0a7-4569-a440-3634a695245f'")
implement(id = 'missing_wid_a8776496-47ff-4246-b7bf-6215daf7b1b1', query = "UPDATE clean_minicensus_main SET wid='408' WHERE instance_id='a8776496-47ff-4246-b7bf-6215daf7b1b1'")
implement(id = 'missing_wid_2f8f0755-7592-4c71-9bf3-418d499b65b8', query = "UPDATE clean_minicensus_main SET wid='398' WHERE instance_id='2f8f0755-7592-4c71-9bf3-418d499b65b8'")
implement(id = 'missing_wid_f9e49d58-6aa1-4d0e-8791-7d5e3c953709', query = "UPDATE clean_minicensus_main SET wid='335' WHERE instance_id='f9e49d58-6aa1-4d0e-8791-7d5e3c953709'")
implement(id = 'missing_wid_6dde710b-a086-4a52-87bf-aad47e848da4', query = "UPDATE clean_minicensus_main SET wid='348' WHERE instance_id='6dde710b-a086-4a52-87bf-aad47e848da4'")
implement(id = 'missing_wid_02a9c5d5-bfe1-47a3-80f4-7f399988dec6', query = "UPDATE clean_minicensus_main SET wid='348' WHERE instance_id='02a9c5d5-bfe1-47a3-80f4-7f399988dec6'")
implement(id = 'missing_wid_4916f22d-fa8c-43a6-bf7d-eeba25f3c44a', query = "UPDATE clean_minicensus_main SET wid='354' WHERE instance_id='4916f22d-fa8c-43a6-bf7d-eeba25f3c44a'")
implement(id = 'missing_wid_693b134c-8418-4a5f-8c0d-e25b28995ebd', query = "UPDATE clean_minicensus_main SET wid='354' WHERE instance_id='693b134c-8418-4a5f-8c0d-e25b28995ebd'")
implement(id = 'missing_wid_40b6b7d4-8202-4a80-9a0f-507731c08d9d', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='40b6b7d4-8202-4a80-9a0f-507731c08d9d'")
implement(id = 'missing_wid_397dcaac-f6bf-4baf-bac0-ee496b7ebe15', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='397dcaac-f6bf-4baf-bac0-ee496b7ebe15'")
implement(id = 'missing_wid_38c1b408-12cb-420d-bbcf-90b1cb804e8b', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='38c1b408-12cb-420d-bbcf-90b1cb804e8b'")
implement(id = 'missing_wid_526f1dce-7fc8-4444-af41-9b946b56ee41', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='526f1dce-7fc8-4444-af41-9b946b56ee41'")
implement(id = 'missing_wid_1567c844-964b-4a4c-8e98-541ba360716c', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='1567c844-964b-4a4c-8e98-541ba360716c'")
implement(id = 'missing_wid_fd66f423-28b1-44f4-b10f-e35732eaf32d', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='fd66f423-28b1-44f4-b10f-e35732eaf32d'")
implement(id = 'missing_wid_9b763dc9-f4a9-40e5-8a25-8fa770769196', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='9b763dc9-f4a9-40e5-8a25-8fa770769196'")
implement(id = 'missing_wid_479aadb9-bb83-4af5-bb16-6eeb774f8f9b', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='479aadb9-bb83-4af5-bb16-6eeb774f8f9b'")
implement(id = 'missing_wid_30bd8d69-7dac-4141-8c37-10eda19b17db', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='30bd8d69-7dac-4141-8c37-10eda19b17db'")
implement(id = 'missing_wid_48de745d-a12b-4b49-b7a8-d26a4ab3b387', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='48de745d-a12b-4b49-b7a8-d26a4ab3b387'")
implement(id = 'missing_wid_0fea26b2-2ccb-4c75-8d6e-a05c2833ae02', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='0fea26b2-2ccb-4c75-8d6e-a05c2833ae02'")
implement(id = 'missing_wid_ef9b91aa-964b-482d-a04d-9c5e7743bf3d', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='ef9b91aa-964b-482d-a04d-9c5e7743bf3d'")
implement(id = 'missing_wid_1d1392f0-5be5-47ea-9285-790557c1315a', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='1d1392f0-5be5-47ea-9285-790557c1315a'")
implement(id = 'missing_wid_654ba44b-6679-4fb8-b49a-a6f64ceaa707', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='654ba44b-6679-4fb8-b49a-a6f64ceaa707'")
implement(id = 'missing_wid_fe1ad858-9ca7-4552-a8c9-2bced746953a', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='fe1ad858-9ca7-4552-a8c9-2bced746953a'")
implement(id = 'missing_wid_3fd9c280-07ee-4394-b588-a1dcb989b81b', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='3fd9c280-07ee-4394-b588-a1dcb989b81b'")
implement(id = 'missing_wid_6f765f56-c825-48cf-aaad-e0795e723824', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='6f765f56-c825-48cf-aaad-e0795e723824'")
implement(id = 'missing_wid_b6951d77-6dd7-4247-b999-c399c025b9b0', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='b6951d77-6dd7-4247-b999-c399c025b9b0'")
implement(id = 'missing_wid_9795d612-b1b8-4631-8ae9-58b48844c0ae', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='9795d612-b1b8-4631-8ae9-58b48844c0ae'")
implement(id = 'missing_wid_6c29924a-2e28-4047-bb05-45fbf2582c66', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='6c29924a-2e28-4047-bb05-45fbf2582c66'")
implement(id = 'missing_wid_289c2197-adab-4492-affd-0994b150b890', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='289c2197-adab-4492-affd-0994b150b890'")
implement(id = 'missing_wid_46eb2722-9aa0-4084-92ae-19509208ae5a', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='46eb2722-9aa0-4084-92ae-19509208ae5a'")
implement(id = 'missing_wid_0fca7ad3-38e8-4846-80ca-ec8957308ff7', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='0fca7ad3-38e8-4846-80ca-ec8957308ff7'")
implement(id = 'missing_wid_a5c73d6c-4a91-489c-be01-812378d4c5d0', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='a5c73d6c-4a91-489c-be01-812378d4c5d0'")
implement(id = 'missing_wid_67fdda31-3264-45b7-ae6d-e03cf190bd06', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='67fdda31-3264-45b7-ae6d-e03cf190bd06'")
implement(id = 'missing_wid_0a3d0bc3-c824-4e17-8faf-3329c6ab7434', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='0a3d0bc3-c824-4e17-8faf-3329c6ab7434'")
implement(id = 'missing_wid_0d3c1c65-60d2-474f-b8c6-b5dbbd6ce26e', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='0d3c1c65-60d2-474f-b8c6-b5dbbd6ce26e'")
implement(id = 'missing_wid_e6e669fe-9316-4005-88eb-cce9212cfcb4', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='e6e669fe-9316-4005-88eb-cce9212cfcb4'")
implement(id = 'missing_wid_57a99a59-a802-4ef0-8fcb-5273a635cb95', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='57a99a59-a802-4ef0-8fcb-5273a635cb95'")
implement(id = 'missing_wid_58107a06-1c7d-4a32-9d6c-6f1b3dc8dfca', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='58107a06-1c7d-4a32-9d6c-6f1b3dc8dfca'")
implement(id = 'missing_wid_0f7e107c-1cdf-4add-947c-586f7a250f9a', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='0f7e107c-1cdf-4add-947c-586f7a250f9a'")
implement(id = 'missing_wid_62e25d19-8014-45df-8df2-50ef8347ecda', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='62e25d19-8014-45df-8df2-50ef8347ecda'")
implement(id = 'missing_wid_6f3ca31d-1986-49f5-93f6-8e0e358d040a', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='6f3ca31d-1986-49f5-93f6-8e0e358d040a'")
implement(id = 'missing_wid_77a299bd-3238-4dda-a906-af92934e24ec', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='77a299bd-3238-4dda-a906-af92934e24ec'")
implement(id = 'missing_wid_7d85d89e-8201-49da-87cb-76e2ea6b62a1', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='7d85d89e-8201-49da-87cb-76e2ea6b62a1'")
implement(id = 'missing_wid_a7a8909a-d739-4a64-a9cc-33f67f037e8c', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='a7a8909a-d739-4a64-a9cc-33f67f037e8c'")
implement(id = 'missing_wid_f6c1af3e-0206-4143-a9e2-8d02583a78f8', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='f6c1af3e-0206-4143-a9e2-8d02583a78f8'")
implement(id = 'missing_wid_b7ddc7c5-d84e-4586-9fd6-7d0da158498c', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='b7ddc7c5-d84e-4586-9fd6-7d0da158498c'")
implement(id = 'missing_wid_2818528a-de66-4a14-88a5-1f31d1e44d76', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='2818528a-de66-4a14-88a5-1f31d1e44d76'")
implement(id = 'missing_wid_44d60341-8a9e-4eea-9345-fe714426c845', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='44d60341-8a9e-4eea-9345-fe714426c845'")
implement(id = 'missing_wid_12a3550a-b857-42e1-88c4-7bd43cba66f0', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='12a3550a-b857-42e1-88c4-7bd43cba66f0'")
implement(id = 'missing_wid_b4f682b9-9e28-4def-a04c-75dee495eeed', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='b4f682b9-9e28-4def-a04c-75dee495eeed'")
implement(id = 'missing_wid_3ded8043-1bc7-45b4-80ff-ef90f1b693f4', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='3ded8043-1bc7-45b4-80ff-ef90f1b693f4'")
implement(id = 'missing_wid_b9815855-af90-4f3c-8a92-5d1f6a58c101', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='b9815855-af90-4f3c-8a92-5d1f6a58c101'")
implement(id = 'missing_wid_bcfee966-65cc-43e2-8170-862c88c07b8a', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='bcfee966-65cc-43e2-8170-862c88c07b8a'")
implement(id = 'missing_wid_badbbc9e-e97c-4377-979a-651cb31e5fef', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='badbbc9e-e97c-4377-979a-651cb31e5fef'")
implement(id = 'missing_wid_849d49e3-b4c2-4fe7-ba3b-abdf4fab4e65', query = "UPDATE clean_minicensus_main SET wid='349' WHERE instance_id='849d49e3-b4c2-4fe7-ba3b-abdf4fab4e65'")
implement(id = 'missing_wid_37ac1ee6-d715-4daf-b6e9-162a6a2a2df2', query = "UPDATE clean_minicensus_main SET wid='412' WHERE instance_id='37ac1ee6-d715-4daf-b6e9-162a6a2a2df2'")
implement(id = 'missing_wid_5c57535c-a4f9-4d4f-8329-20effec52ff3', query = "UPDATE clean_minicensus_main SET wid='412' WHERE instance_id='5c57535c-a4f9-4d4f-8329-20effec52ff3'")
implement(id = 'missing_wid_0bad5d2d-1ea8-4824-bb42-bbabc8f81c66', query = "UPDATE clean_minicensus_main SET wid='412' WHERE instance_id='0bad5d2d-1ea8-4824-bb42-bbabc8f81c66'")
implement(id = 'missing_wid_76e28b23-f5a3-40fa-9f2c-84ec847473fd', query = "UPDATE clean_minicensus_main SET wid='412' WHERE instance_id='76e28b23-f5a3-40fa-9f2c-84ec847473fd'")
implement(id = 'missing_wid_a82413f0-bbd6-4f9b-88e4-3428d4f7bf25', query = "UPDATE clean_minicensus_main SET wid='412' WHERE instance_id='a82413f0-bbd6-4f9b-88e4-3428d4f7bf25'")
implement(id = 'missing_wid_7b388b0a-38d9-4f81-9f56-64e7ec13bc2f', query = "UPDATE clean_minicensus_main SET wid='412' WHERE instance_id='7b388b0a-38d9-4f81-9f56-64e7ec13bc2f'")
implement(id = 'missing_wid_0f30ff8b-a233-4f0b-a3ca-2ff5da991635', query = "UPDATE clean_minicensus_main SET wid='412' WHERE instance_id='0f30ff8b-a233-4f0b-a3ca-2ff5da991635'")
implement(id = 'missing_wid_7baa064a-1c3d-4d1c-bcba-b81edac8bea2', query = "UPDATE clean_minicensus_main SET wid='421' WHERE instance_id='7baa064a-1c3d-4d1c-bcba-b81edac8bea2'")
implement(id = 'missing_wid_092f9a81-f8d0-479e-ba81-433df9e243bc', query = "UPDATE clean_minicensus_main SET wid='421' WHERE instance_id='092f9a81-f8d0-479e-ba81-433df9e243bc'")
implement(id = 'missing_wid_269a652c-3234-44c2-9cb8-f9dcdad6a8dc', query = "UPDATE clean_minicensus_main SET wid='421' WHERE instance_id='269a652c-3234-44c2-9cb8-f9dcdad6a8dc'")
implement(id = 'missing_wid_786fbc99-9742-44f9-8d53-535f2c2e761f', query = "UPDATE clean_minicensus_main SET wid='421' WHERE instance_id='786fbc99-9742-44f9-8d53-535f2c2e761f'")
implement(id = 'no_va_id_a4164c67-db00-4a73-8f78-b1c81e9097ae', query = "UPDATE clean_va SET death_id='CHM-060-701' WHERE instance_id='a4164c67-db00-4a73-8f78-b1c81e9097ae'")
implement(id = 'no_va_id_4eab381e-23ba-4732-90fb-c9dbf3bbfd27', query = "UPDATE clean_va SET death_id='CHM-121-701' WHERE instance_id='4eab381e-23ba-4732-90fb-c9dbf3bbfd27'")
implement(id = 'no_va_id_5abf5d22-63cb-4281-bc6d-bc4128662c09', query = "UPDATE clean_va SET death_id='DAN-058-701' WHERE instance_id='5abf5d22-63cb-4281-bc6d-bc4128662c09'")
implement(id = 'no_va_id_2d79529d-3cbd-44af-a2a4-4fa32485af49', query = "UPDATE clean_va SET death_id='DAN-074-701' WHERE instance_id='2d79529d-3cbd-44af-a2a4-4fa32485af49'")
implement(id = 'no_va_id_b5384c28-7c24-49b6-b22e-56d367264446', query = "UPDATE clean_va SET death_id='DEJ-010-701' WHERE instance_id='b5384c28-7c24-49b6-b22e-56d367264446'")
implement(id = 'no_va_id_4cb428bb-56ed-48ca-9717-3aaa7d4fd8c2', query = "UPDATE clean_va SET death_id='DEO-046-701' WHERE instance_id='4cb428bb-56ed-48ca-9717-3aaa7d4fd8c2'")
implement(id = 'no_va_id_e577fd76-92ff-434b-9879-7401446d0dd9', query = "UPDATE clean_va SET death_id='DEU-094-701' WHERE instance_id='e577fd76-92ff-434b-9879-7401446d0dd9'")
implement(id = 'no_va_id_19fc2aa4-bdfa-4a8d-9ff2-4529adaec166', query = "UPDATE clean_va SET death_id='DEU-129-701' WHERE instance_id='19fc2aa4-bdfa-4a8d-9ff2-4529adaec166'")
implement(id = 'no_va_id_ea7fb4ca-ee7f-4fb3-abd9-f46fa0c63fff', query = "UPDATE clean_va SET death_id='DEX-025-701' WHERE instance_id='ea7fb4ca-ee7f-4fb3-abd9-f46fa0c63fff'")
implement(id = 'no_va_id_3ded4c70-9462-4eb9-9ff4-56a16775e480', query = "UPDATE clean_va SET death_id='DEX-089-701' WHERE instance_id='3ded4c70-9462-4eb9-9ff4-56a16775e480'")
implement(id = 'no_va_id_76a3fecd-c548-40cb-837b-42f8d131d9f9', query = "UPDATE clean_va SET death_id='DEX-140-701' WHERE instance_id='76a3fecd-c548-40cb-837b-42f8d131d9f9'")
implement(id = 'no_va_id_b3252dd2-0ad0-44aa-9e9c-eb0dfcae194a', query = "UPDATE clean_va SET death_id='DEX-261-701' WHERE instance_id='b3252dd2-0ad0-44aa-9e9c-eb0dfcae194a'")
implement(id = 'no_va_id_27c848ea-5529-48a2-b0eb-fbf57b8ca289', query = "UPDATE clean_va SET death_id='DEX-292-701' WHERE instance_id='27c848ea-5529-48a2-b0eb-fbf57b8ca289'")
implement(id = 'no_va_id_44f99f03-b0f8-4e06-b89b-383d820f53e5', query = "UPDATE clean_va SET death_id='EDU-014-701' WHERE instance_id='44f99f03-b0f8-4e06-b89b-383d820f53e5'")
# implement(id = 'no_va_id_f754caea-0a7d-42c9-a6af-a52d18a1e8ae', query = "UPDATE clean_va SET death_id='EDU-196-701' WHERE instance_id='f754caea-0a7d-42c9-a6af-a52d18a1e8ae'")
# implement(id = 'no_va_id_bbdbf1a0-f892-49d7-b8d0-dc176042d734', query = "UPDATE clean_va SET death_id='EDU-196-701' WHERE instance_id='bbdbf1a0-f892-49d7-b8d0-dc176042d734'")
# implement(id = 'no_va_id_3bf921f9-dc51-4f88-baea-8f588074b7bf', query = "UPDATE clean_va SET death_id='EDU-196-701' WHERE instance_id='3bf921f9-dc51-4f88-baea-8f588074b7bf'")
# implement(id = 'no_va_id_d969f990-5e43-4e0a-8df9-e8c13ea78fa9', query = "UPDATE clean_va SET death_id='EDU-196-701' WHERE instance_id='d969f990-5e43-4e0a-8df9-e8c13ea78fa9'")
implement(id = 'no_va_id_cd6f20f7-b292-481d-af33-6a5b0cd41d5d', query = "UPDATE clean_va SET death_id='FFF-046-701' WHERE instance_id='cd6f20f7-b292-481d-af33-6a5b0cd41d5d'")
implement(id = 'no_va_id_1bddf446-393d-42d7-b73a-3ded7b42f4b9', query = "UPDATE clean_va SET death_id='JSA-077-701' WHERE instance_id='1bddf446-393d-42d7-b73a-3ded7b42f4b9'")
# implement(id = 'no_va_id_2c064504-fa15-4672-9815-ca9f9ca852c8', query = "UPDATE clean_va SET death_id='JSA-085-701' WHERE instance_id='2c064504-fa15-4672-9815-ca9f9ca852c8'")
# implement(id = 'no_va_id_f5912455-1921-4632-9007-45d8300e7f3e', query = "UPDATE clean_va SET death_id='JSA-085-701' WHERE instance_id='f5912455-1921-4632-9007-45d8300e7f3e'")
implement(id = 'no_va_id_83ce759a-3e04-49c1-9ddd-a2f1d73ffe47', query = "UPDATE clean_va SET death_id='LIE-018-701' WHERE instance_id='83ce759a-3e04-49c1-9ddd-a2f1d73ffe47'")
implement(id = 'no_va_id_c25b68ed-503c-4113-911c-d4dc41026728', query = "UPDATE clean_va SET death_id='LIE-055-701' WHERE instance_id='c25b68ed-503c-4113-911c-d4dc41026728'")
implement(id = 'no_va_id_1162212c-05d3-4303-afaf-1325d9a02b71', query = "UPDATE clean_va SET death_id='MAL-023-701' WHERE instance_id='1162212c-05d3-4303-afaf-1325d9a02b71'")
implement(id = 'no_va_id_7d405f78-5ba4-458b-851a-183c1caa6136', query = "UPDATE clean_va SET death_id='MAL-150-701' WHERE instance_id='7d405f78-5ba4-458b-851a-183c1caa6136'")
implement(id = 'no_va_id_2838afb4-dec4-4ad7-9f79-a6c9d4cf8c57', query = "UPDATE clean_va SET death_id='MIF-028-701' WHERE instance_id='2838afb4-dec4-4ad7-9f79-a6c9d4cf8c57'")
implement(id = 'no_va_id_394c787f-c29c-453a-85a3-d53b9c08cd97', query = "UPDATE clean_va SET death_id='MIF-078-701' WHERE instance_id='394c787f-c29c-453a-85a3-d53b9c08cd97'")
implement(id = 'no_va_id_794fa1c6-6eb4-4c4c-beba-fb20eb045a71', query = "UPDATE clean_va SET death_id='MUR-013-701' WHERE instance_id='794fa1c6-6eb4-4c4c-beba-fb20eb045a71'")
implement(id = 'no_va_id_50f65f14-858c-4a59-bdb2-23c2b84c4986', query = "UPDATE clean_va SET death_id='MUR-050-701' WHERE instance_id='50f65f14-858c-4a59-bdb2-23c2b84c4986'")
implement(id = 'no_va_id_62b578fe-2651-4fe1-a1d2-4ce7d8bac96e', query = "UPDATE clean_va SET death_id='MUR-082-701' WHERE instance_id='62b578fe-2651-4fe1-a1d2-4ce7d8bac96e'")
implement(id = 'no_va_id_a809e802-fa58-4d22-ba57-8d2b0000bb2a', query = "UPDATE clean_va SET death_id='MUR-092-701' WHERE instance_id='a809e802-fa58-4d22-ba57-8d2b0000bb2a'")
implement(id = 'no_va_id_5e6a611c-8320-4915-8039-84e1d018eff0', query = "UPDATE clean_va SET death_id='MUR-059-701' WHERE instance_id='5e6a611c-8320-4915-8039-84e1d018eff0'")
implement(id = 'no_va_id_c5caa4f7-ae42-45d9-a363-7f24a541807f', query = "UPDATE clean_va SET death_id='MUT-075-701' WHERE instance_id='c5caa4f7-ae42-45d9-a363-7f24a541807f'")
# implement(id = 'no_va_id_e45d94f8-c4ce-4d8d-bfe2-20a9704a3863', query = "UPDATE clean_va SET death_id='NXG-013-701' WHERE instance_id='e45d94f8-c4ce-4d8d-bfe2-20a9704a3863'")
# implement(id = 'no_va_id_d5b4442c-af42-411c-ab25-5b2641681c52', query = "UPDATE clean_va SET death_id='NXG-013-701' WHERE instance_id='d5b4442c-af42-411c-ab25-5b2641681c52'")
# implement(id = 'no_va_id_ab45b465-93b8-4884-b03f-4615c5ea1af6', query = "UPDATE clean_va SET death_id='NXG-013-701' WHERE instance_id='ab45b465-93b8-4884-b03f-4615c5ea1af6'")
implement(id = 'no_va_id_f6c4ed2f-012a-4025-b8b5-e7d23ec8d06b', query = "UPDATE clean_va SET death_id='XAM-051-701' WHERE instance_id='f6c4ed2f-012a-4025-b8b5-e7d23ec8d06b'")
implement(id = 'no_va_id_9a3207b7-6925-4441-b834-723ae93af283', query = "UPDATE clean_va SET death_id='ZVB-263-701' WHERE instance_id='9a3207b7-6925-4441-b834-723ae93af283'")
implement(id = 'no_va_id_c6a098bb-55f8-4160-a6e5-5f2afbe9082e', query = "UPDATE clean_va SET death_id='ZVB-286-701' WHERE instance_id='c6a098bb-55f8-4160-a6e5-5f2afbe9082e'")
implement(id = 'no_va_id_f754caea-0a7d-42c9-a6af-a52d18a1e8ae', query = "UPDATE clean_va SET death_id='EDU-196-701' WHERE instance_id='f754caea-0a7d-42c9-a6af-a52d18a1e8ae'")
# fixed hamlet codes and verified that no changes are needed to household members' pid or permid (except in case where it has been updated) in the following 24 corrections
implement(id = 'strange_hh_code_00f5b8ba-739c-428d-ae19-27f2be92044e', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='DEO', hh_village='Marruma', hh_hamlet='4 de Outubro' WHERE instance_id='00f5b8ba-739c-428d-ae19-27f2be92044e'", who = 'Xing Brew')
implement(id = 'strange_hh_code_0f15fdb4-3b7a-41a3-8fa4-1abe03849212', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha', hh_ward='Mopeia sede | Cuacua' WHERE instance_id='0f15fdb4-3b7a-41a3-8fa4-1abe03849212'", who = 'Xing Brew')
implement(id = 'strange_hh_code_1b6a9ce2-8d36-4136-869d-a117f0192449', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='AMB', hh_village='Chamanga', hh_hamlet='Ambrosio' WHERE instance_id='1b6a9ce2-8d36-4136-869d-a117f0192449'", who = 'Xing Brew')
implement(id = 'strange_hh_code_2624afc1-f262-4bda-b20f-34176ed1c13b', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='2624afc1-f262-4bda-b20f-34176ed1c13b'", who = 'Xing Brew')
implement(id = 'strange_hh_code_287b28f8-c6ba-4b4e-bd6f-b6778a729d93', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='DEO', hh_village='Marruma', hh_hamlet='4 de Outubro', hh_id='DEO-033' WHERE instance_id='287b28f8-c6ba-4b4e-bd6f-b6778a729d93'; UPDATE clean_minicensus_people SET pid='DEO-033-001', permid='DEO-033-001' WHERE num='1' and instance_id='287b28f8-c6ba-4b4e-bd6f-b6778a729d93'; UPDATE clean_minicensus_people SET pid='DEO-033-002', permid='DEO-033-002' WHERE num='2' and instance_id='287b28f8-c6ba-4b4e-bd6f-b6778a729d93'; UPDATE clean_minicensus_people SET pid='DEO-033-003', permid='DEO-033-003' WHERE num='3' and instance_id='287b28f8-c6ba-4b4e-bd6f-b6778a729d93'; UPDATE clean_minicensus_people SET pid='DEO-033-004', permid='DEO-033-004' WHERE num='4' and instance_id='287b28f8-c6ba-4b4e-bd6f-b6778a729d93'; UPDATE clean_minicensus_people SET pid='DEO-033-005', permid='DEO-033-005' WHERE num='5' and instance_id='287b28f8-c6ba-4b4e-bd6f-b6778a729d93'; UPDATE clean_minicensus_people SET pid='DEO-033-006', permid='DEO-033-006' WHERE num='6' and instance_id='287b28f8-c6ba-4b4e-bd6f-b6778a729d93'; UPDATE clean_minicensus_people SET pid='DEO-033-007', permid='DEO-033-007' WHERE num='7' and instance_id='287b28f8-c6ba-4b4e-bd6f-b6778a729d93'", who = 'Xing Brew')
implement(id = 'strange_hh_code_2c54e783-2281-429f-9896-060261a148db', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='2c54e783-2281-429f-9896-060261a148db'", who = 'Xing Brew')
implement(id = 'strange_hh_code_3f6c7281-a596-43cb-9af5-d7ef71858b3d', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='3f6c7281-a596-43cb-9af5-d7ef71858b3d'", who = 'Xing Brew')
implement(id = 'strange_hh_code_4320edeb-a6b7-4142-8cd5-c99b697ab8b1', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='4320edeb-a6b7-4142-8cd5-c99b697ab8b1'", who = 'Xing Brew')
implement(id = 'strange_hh_code_44a1e42c-5368-48f6-8a2d-eebd5a2c7ea0', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='44a1e42c-5368-48f6-8a2d-eebd5a2c7ea0'", who = 'Xing Brew')
implement(id = 'strange_hh_code_4c53beaf-5154-48f8-a336-cec7963f404d', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='AMB', hh_village='Chamanga', hh_hamlet='Ambrosio' WHERE instance_id='4c53beaf-5154-48f8-a336-cec7963f404d'", who = 'Xing Brew')
implement(id = 'strange_hh_code_4db44ad4-e20a-4138-a384-645cc677eaba', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='4db44ad4-e20a-4138-a384-645cc677eaba'", who = 'Xing Brew')
implement(id = 'strange_hh_code_5cdcec09-b92c-4bae-861f-f380b9a94039', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='5cdcec09-b92c-4bae-861f-f380b9a94039'", who = 'Xing Brew')
implement(id = 'strange_hh_code_5e705909-9643-4b50-83f0-8c4f2594d728', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='5e705909-9643-4b50-83f0-8c4f2594d728'", who = 'Xing Brew')
implement(id = 'strange_hh_code_71c25f31-6fa8-46f6-9285-f884f9d546cb', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='71c25f31-6fa8-46f6-9285-f884f9d546cb'", who = 'Xing Brew')
implement(id = 'strange_hh_code_77598a24-0d8a-4ae9-81cc-73c5879ca4f4', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='77598a24-0d8a-4ae9-81cc-73c5879ca4f4'", who = 'Xing Brew')
implement(id = 'strange_hh_code_7872d175-61eb-494e-b70f-ac60a71cf0d6', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='AMB', hh_village='Chamanga', hh_hamlet='Ambrosio' WHERE instance_id='7872d175-61eb-494e-b70f-ac60a71cf0d6'", who = 'Xing Brew')
implement(id = 'strange_hh_code_8503d0cc-e5a9-475f-839b-c3c2ab522465', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='AMB', hh_village='Chamanga', hh_hamlet='Ambrosio' WHERE instance_id='8503d0cc-e5a9-475f-839b-c3c2ab522465'", who = 'Xing Brew')
implement(id = 'strange_hh_code_877f5c2a-1598-429c-98a1-5791976378e2', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='DEO', hh_village='Marruma'', hh_hamlet='4 de Outubro' WHERE instance_id='877f5c2a-1598-429c-98a1-5791976378e2'", who = 'Xing Brew')
implement(id = 'strange_hh_code_8ece72fe-bbc4-4bbf-9768-c914476b1206', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='8ece72fe-bbc4-4bbf-9768-c914476b1206'", who = 'Xing Brew')
implement(id = 'strange_hh_code_912a3d2d-a059-477c-8911-945ba506758e', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='DEO', hh_village='Marruma', hh_hamlet='4 de Outubro' WHERE instance_id='912a3d2d-a059-477c-8911-945ba506758e'", who = 'Xing Brew')
implement(id = 'strange_hh_code_bda16440-1171-4691-95a1-0e55527e0c33', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='bda16440-1171-4691-95a1-0e55527e0c33'", who = 'Xing Brew')
implement(id = 'strange_hh_code_c867866e-b703-4fe2-a9a7-50d31cfdea09', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='DEO', hh_village='Marruma', hh_hamlet='4 de Outubro' WHERE instance_id='c867866e-b703-4fe2-a9a7-50d31cfdea09'", who = 'Xing Brew')
implement(id = 'strange_hh_code_cc891eb8-e320-4272-a490-ad8045dc1689', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='cc891eb8-e320-4272-a490-ad8045dc1689'", who = 'Xing Brew')
implement(id = 'strange_wid_enumerations_2939b05a-3bbe-4c1b-81fe-6eac54d47dc9', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='2939b05a-3bbe-4c1b-81fe-6eac54d47dc9'", who = 'Xing Brew')
 

# TZA
implement(id = 'strange_wid_5f466226-1d75-40a9-97fc-5e8cd84448c9', query = "UPDATE clean_minicensus_main SET wid='37' WHERE instance_id='5f466226-1d75-40a9-97fc-5e8cd84448c9'")
implement(id = 'missing_wid_23632449-cb8d-4ea2-a705-4d9f145b352c', query = "UPDATE clean_minicensus_main SET wid='80' WHERE instance_id='23632449-cb8d-4ea2-a705-4d9f145b352c'")
implement(id = 'missing_wid_ee4aca39-2370-49c2-a01e-a295638038e9', query = "UPDATE clean_minicensus_main SET wid='14' WHERE instance_id='ee4aca39-2370-49c2-a01e-a295638038e9'")
implement(id = 'repeat_hh_id_564fe4e1-1978-4bc5-84b4-d80adb7a9bde,7ac74d0a-7eb9-4651-a2a6-ee7d8edd7059', query = "DELETE FROM clean_minicensus_main WHERE instance_id='7ac74d0a-7eb9-4651-a2a6-ee7d8edd7059'")
implement(id = 'repeat_hh_id_36527774-d88c-4b97-8722-b881171ff77c,3be77a06-5646-49fe-9037-f0ff3bc40543', query = "DELETE FROM clean_minicensus_main WHERE instance_id='36527774-d88c-4b97-8722-b881171ff77c'")

dbconn.commit()
cur.close()
dbconn.close()
