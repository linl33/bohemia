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
show_these = do_these[['resolved_by', 'submitted_at', 'id', 'response_details', 'instance_id']]
show_these.to_csv('/tmp/show_these.csv') # to help human

# Define function for implementing corrections
def implement(id = None, query = '', who = 'Joe Brew', is_ok = False, cur = cur, dbconn = dbconn):
  # Implement the actual fix to the database
  if not is_ok:
  try:
  # print('Executing this query:\n')
  # print(query)
  cur.execute(query)
except:
  cur.execute("ROLLBACK")
print('Problem executing:\n')
print(query)
return
done_at = datetime.now()
# State the fact that it has been fixed
if id is not None:
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
implement(id = 'no_va_id_cd6f20f7-b292-481d-af33-6a5b0cd41d5d', query = "UPDATE clean_va SET death_id='FFF-046-701' WHERE instance_id='cd6f20f7-b292-481d-af33-6a5b0cd41d5d'")
implement(id = 'no_va_id_1bddf446-393d-42d7-b73a-3ded7b42f4b9', query = "UPDATE clean_va SET death_id='JSA-077-701' WHERE instance_id='1bddf446-393d-42d7-b73a-3ded7b42f4b9'")
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
implement(id = 'strange_hh_code_877f5c2a-1598-429c-98a1-5791976378e2', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='DEO', hh_village='Marruma', hh_hamlet='4 de Outubro' WHERE instance_id='877f5c2a-1598-429c-98a1-5791976378e2'", who = 'Xing Brew')
implement(id = 'strange_hh_code_8ece72fe-bbc4-4bbf-9768-c914476b1206', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='8ece72fe-bbc4-4bbf-9768-c914476b1206'", who = 'Xing Brew')
implement(id = 'strange_hh_code_912a3d2d-a059-477c-8911-945ba506758e', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='DEO', hh_village='Marruma', hh_hamlet='4 de Outubro' WHERE instance_id='912a3d2d-a059-477c-8911-945ba506758e'", who = 'Xing Brew')
implement(id = 'strange_hh_code_bda16440-1171-4691-95a1-0e55527e0c33', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='bda16440-1171-4691-95a1-0e55527e0c33'", who = 'Xing Brew')
implement(id = 'strange_hh_code_c867866e-b703-4fe2-a9a7-50d31cfdea09', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='DEO', hh_village='Marruma', hh_hamlet='4 de Outubro' WHERE instance_id='c867866e-b703-4fe2-a9a7-50d31cfdea09'", who = 'Xing Brew')
implement(id = 'strange_hh_code_cc891eb8-e320-4272-a490-ad8045dc1689', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='cc891eb8-e320-4272-a490-ad8045dc1689'", who = 'Xing Brew')
implement(id = 'strange_wid_enumerations_2939b05a-3bbe-4c1b-81fe-6eac54d47dc9', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='2939b05a-3bbe-4c1b-81fe-6eac54d47dc9'", who = 'Xing Brew')
implement(id = 'strange_hh_code_1e0e5093-ac9e-4f24-aedb-5c1fc18b9439', query = "UPDATE clean_minicensus_main SET hh_hamlet_code='MIF', hh_village='Marruma', hh_hamlet='Mifarinha' WHERE instance_id='1e0e5093-ac9e-4f24-aedb-5c1fc18b9439'", who = 'Jaume')
implement(id = 'strange_wid_4eed4b20-6197-4694-9359-b19708e692bc', query = "UPDATE clean_minicensus_main SET wid='392' WHERE instance_id='4eed4b20-6197-4694-9359-b19708e692bc'", who = 'Jaume')
implement(id = 'strange_wid_73cea41e-c35f-4d8a-823c-d3780e41c510', query = "UPDATE clean_minicensus_main SET wid='28' WHERE instance_id='73cea41e-c35f-4d8a-823c-d3780e41c510'", who = 'Jaume')

iid = "'b1b160bd-8616-4a13-a001-903fd94daffa'"
implement(id = 'repeat_hh_id_b1b160bd-8616-4a13-a001-903fd94daffa,e7263ebd-ae5e-4493-b053-b2148796507f', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'f3c073b4-e0b5-4027-9527-996861dd1b80'"
implement(id = 'repeat_hh_id_f105ac83-1ef5-445a-ae5f-62f9e49a97c0,f3c073b4-e0b5-4027-9527-996861dd1b80', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'6d0a71d0-8dff-4ae7-a82c-7b861ab05a7b'"
implement(id = 'repeat_hh_id_6d0a71d0-8dff-4ae7-a82c-7b861ab05a7b,f64247c8-cd98-4221-b7de-60d9d310b3a1', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'32338a6c-29b4-4e19-8476-916fdb54848d'"
implement(id = 'repeat_hh_id_32338a6c-29b4-4e19-8476-916fdb54848d,78c379a5-b886-490e-8f19-b1c766077f31', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'eafbc597-74ca-4dbc-84e5-4529ff3d5a15'"
implement(id = 'repeat_hh_id_eafbc597-74ca-4dbc-84e5-4529ff3d5a15,fcdda43d-821f-4fda-bfbc-ed94cb7fa0ba', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'0462b38a-738b-4bef-baad-7157b4368790'"
implement(id = 'repeat_hh_id_0462b38a-738b-4bef-baad-7157b4368790,7207712b-c086-4b04-ad4b-2bc85f9065ea', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'2f9f04fd-b9a2-45e7-ab66-62c647ed350a'"
implement(id = 'repeat_hh_id_2f9f04fd-b9a2-45e7-ab66-62c647ed350a,a0bdbe89-b911-4e15-b1de-adc3fd90fa00', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'2b0e0656-6be8-4fd5-a97a-74b9cb544a2b'"
implement(id = 'repeat_hh_id_2b0e0656-6be8-4fd5-a97a-74b9cb544a2b,ca0a830a-cb97-4e89-a8f5-a9ed940de44b', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'428c522f-34aa-47c6-b9dd-be0ab3895bc0'"
implement(id = 'strange_wid_428c522f-34aa-47c6-b9dd-be0ab3895bc0', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Joe Brew')

iid = "'86c9211e-09e8-424d-9fb0-837f776681d4'"
implement(id = 'strange_wid_86c9211e-09e8-424d-9fb0-837f776681d4', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Joe Brew')

iid = "'d92d102a-d420-4477-901d-1cff1cdf5bf3'"
implement(id = 'strange_wid_d92d102a-d420-4477-901d-1cff1cdf5bf3', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Joe Brew')

iid = "'1d655652-8683-4c23-8c7c-026c96c2d916'"
implement(id = 'strange_wid_1d655652-8683-4c23-8c7c-026c96c2d916', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Joe Brew')

iid = "'177c9b70-6f80-4871-a8d4-3091388332fd'"
implement(id = 'strange_wid_177c9b70-6f80-4871-a8d4-3091388332fd', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Joe Brew')

iid = "'ef82e63c-a09c-4b81-83c4-ce3bb9225484'"
implement(id = 'strange_wid_ef82e63c-a09c-4b81-83c4-ce3bb9225484', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_00abd9be-9a4c-4c68-9067-865118f9f3f5', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='00abd9be-9a4c-4c68-9067-865118f9f3f5'")
implement(id = 'strange_wid_enumerations_019b4608-271c-446c-b9c3-20e9030e0d99', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='019b4608-271c-446c-b9c3-20e9030e0d99'")
implement(id = 'strange_wid_enumerations_01dd7b29-9a2a-4216-9101-0db57a35703d', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='01dd7b29-9a2a-4216-9101-0db57a35703d'")
implement(id = 'strange_wid_enumerations_020dc42e-6054-4895-b540-0564b9bed99d', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='020dc42e-6054-4895-b540-0564b9bed99d'")
implement(id = 'strange_wid_enumerations_02720e92-ddfe-455c-9ac2-74a8342a17ab', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='02720e92-ddfe-455c-9ac2-74a8342a17ab'")
implement(id = 'strange_wid_enumerations_032674a4-74b7-439b-9b16-9ae534bf489d', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='032674a4-74b7-439b-9b16-9ae534bf489d'")
implement(id = 'strange_wid_enumerations_03a7b6de-b9aa-487d-ad53-15720bf85876', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='03a7b6de-b9aa-487d-ad53-15720bf85876'")
implement(id = 'strange_wid_enumerations_04c9529b-870a-4d99-873e-70fa946ea8ee', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='04c9529b-870a-4d99-873e-70fa946ea8ee'")
implement(id = 'strange_wid_enumerations_05dcc9e8-1a37-4167-885d-10d6176f00a7', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='05dcc9e8-1a37-4167-885d-10d6176f00a7'")
implement(id = 'strange_wid_enumerations_064eaece-d377-4dcd-80cd-0698a46b0384', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='064eaece-d377-4dcd-80cd-0698a46b0384'")
implement(id = 'strange_wid_enumerations_06536691-0e92-4b62-8f9d-f5a6433619e6', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='06536691-0e92-4b62-8f9d-f5a6433619e6'")
implement(id = 'strange_wid_enumerations_077b833c-d2a6-41a8-bae2-03e1ccbbd294', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='077b833c-d2a6-41a8-bae2-03e1ccbbd294'")
implement(id = 'strange_wid_enumerations_080ad32e-873c-481a-9a71-dedee12b7875', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='080ad32e-873c-481a-9a71-dedee12b7875'")
implement(id = 'strange_wid_enumerations_0831116e-7aca-4047-99f0-df791040a294', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='0831116e-7aca-4047-99f0-df791040a294'")
implement(id = 'strange_wid_enumerations_08f37dca-90f1-48c9-a3c8-00b68cd273aa', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='08f37dca-90f1-48c9-a3c8-00b68cd273aa'")
implement(id = 'strange_wid_enumerations_09efc086-7ec1-42a4-b672-a8a2d8464430', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='09efc086-7ec1-42a4-b672-a8a2d8464430'")
implement(id = 'strange_wid_enumerations_0cc7bf3d-e19f-4bc0-8c01-df33a0fe14e3', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='0cc7bf3d-e19f-4bc0-8c01-df33a0fe14e3'")
implement(id = 'strange_wid_enumerations_0ccbdc72-137a-45ca-b9c3-f510386f4d48', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='0ccbdc72-137a-45ca-b9c3-f510386f4d48'")
implement(id = 'strange_wid_enumerations_0e552a1d-1e89-48fe-b7a5-0d15928f3ddc', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='0e552a1d-1e89-48fe-b7a5-0d15928f3ddc'")
implement(id = 'strange_wid_enumerations_0e6a0ef7-87ea-43bb-b71c-8ee14cd82b7b', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='0e6a0ef7-87ea-43bb-b71c-8ee14cd82b7b'")
implement(id = 'strange_wid_enumerations_0ed6c81a-36cd-4cf0-8160-63ce49cd17b1', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='0ed6c81a-36cd-4cf0-8160-63ce49cd17b1'")
implement(id = 'strange_wid_enumerations_0f043162-623a-47b6-a378-6ad3cd4b10d7', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='0f043162-623a-47b6-a378-6ad3cd4b10d7'")
implement(id = 'strange_wid_enumerations_10423d3a-7823-4cd3-9536-8f381b99afef', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='10423d3a-7823-4cd3-9536-8f381b99afef'")
implement(id = 'strange_wid_enumerations_1094286c-d9e1-419e-a229-5f4040495520', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='1094286c-d9e1-419e-a229-5f4040495520'")
implement(id = 'strange_wid_enumerations_11cfd8bb-c7c9-40e7-b5e8-a6193c48a56a', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='11cfd8bb-c7c9-40e7-b5e8-a6193c48a56a'")
implement(id = 'strange_wid_enumerations_123bc7d2-4fa2-4041-ab2d-9b970dd5d69e', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='123bc7d2-4fa2-4041-ab2d-9b970dd5d69e'")
implement(id = 'strange_wid_enumerations_12928af2-f496-4ff4-b5bc-d56ea9a800d5', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='12928af2-f496-4ff4-b5bc-d56ea9a800d5'")
implement(id = 'strange_wid_enumerations_12942533-4c02-4704-8d94-999643e358f5', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='12942533-4c02-4704-8d94-999643e358f5'")
implement(id = 'strange_wid_enumerations_12b54674-efc2-4216-8495-11374acc3d2c', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='12b54674-efc2-4216-8495-11374acc3d2c'")
implement(id = 'strange_wid_enumerations_130dd196-2e0c-4aea-a99f-a03958eafbb4', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='130dd196-2e0c-4aea-a99f-a03958eafbb4'")
implement(id = 'strange_wid_enumerations_13999d6f-dce8-48f7-a351-7cec8dd8429f', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='13999d6f-dce8-48f7-a351-7cec8dd8429f'")
implement(id = 'strange_wid_enumerations_140bd62d-7332-4047-8638-928b77c550d1', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='140bd62d-7332-4047-8638-928b77c550d1'")
implement(id = 'strange_wid_enumerations_143eb4c4-682b-4a1a-86de-072775b824e3', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='143eb4c4-682b-4a1a-86de-072775b824e3'")
implement(id = 'strange_wid_enumerations_1476dcb8-eec4-4c50-89e1-4c9f3c017835', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='1476dcb8-eec4-4c50-89e1-4c9f3c017835'")
implement(id = 'strange_wid_enumerations_148d8cea-c44e-47a8-b5c9-621bc292ad2c', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='148d8cea-c44e-47a8-b5c9-621bc292ad2c'")
implement(id = 'strange_wid_enumerations_15babe2a-c871-403a-9f72-f944ebd09908', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='15babe2a-c871-403a-9f72-f944ebd09908'")
implement(id = 'strange_wid_enumerations_15dd8d05-ac93-470f-be72-1b9c57016599', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='15dd8d05-ac93-470f-be72-1b9c57016599'")
implement(id = 'strange_wid_enumerations_16982623-6629-40d0-a8c0-4347fc5e26ad', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='16982623-6629-40d0-a8c0-4347fc5e26ad'")
implement(id = 'strange_wid_enumerations_17a325dc-d704-408a-bd61-251412a3b913', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='17a325dc-d704-408a-bd61-251412a3b913'")
implement(id = 'strange_wid_enumerations_19666d18-5979-4c68-9fe4-91845bc7c447', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='19666d18-5979-4c68-9fe4-91845bc7c447'")
implement(id = 'strange_wid_enumerations_19940579-6093-49d2-946d-5f81da3bcc65', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='19940579-6093-49d2-946d-5f81da3bcc65'")
implement(id = 'strange_wid_enumerations_19dc2605-66f3-4b85-aa44-9bd6c70b6a22', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='19dc2605-66f3-4b85-aa44-9bd6c70b6a22'")
implement(id = 'strange_wid_enumerations_1aff20ac-b27f-4869-a768-38badda88f68', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='1aff20ac-b27f-4869-a768-38badda88f68'")
implement(id = 'strange_wid_enumerations_1be2b28a-331e-491d-b9e6-756a650e969f', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='1be2b28a-331e-491d-b9e6-756a650e969f'")
implement(id = 'strange_wid_enumerations_1be9e7c0-9143-47c2-b03c-a123be6eaafb', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='1be9e7c0-9143-47c2-b03c-a123be6eaafb'")
implement(id = 'strange_wid_enumerations_1c3956d7-a4cb-400e-8ea2-b162b28b83ca', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='1c3956d7-a4cb-400e-8ea2-b162b28b83ca'")
implement(id = 'strange_wid_enumerations_1c8448fa-557e-46c4-9f15-d041927051dd', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='1c8448fa-557e-46c4-9f15-d041927051dd'")
implement(id = 'strange_wid_enumerations_1cc6860e-ee29-4a9d-a8d7-7e5a5e14c363', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='1cc6860e-ee29-4a9d-a8d7-7e5a5e14c363'")
implement(id = 'strange_wid_enumerations_1d83f43d-4da2-4dc8-99f2-904746e3cb3f', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='1d83f43d-4da2-4dc8-99f2-904746e3cb3f'")
implement(id = 'strange_wid_enumerations_1daa2037-0315-4962-ab11-e765b1aa2553', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='1daa2037-0315-4962-ab11-e765b1aa2553'")
implement(id = 'strange_wid_enumerations_1e13a715-a29b-4682-a52b-da7f5118663c', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='1e13a715-a29b-4682-a52b-da7f5118663c'")
implement(id = 'strange_wid_enumerations_1e8f0103-5665-471e-937d-3984364a0643', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='1e8f0103-5665-471e-937d-3984364a0643'")
implement(id = 'strange_wid_enumerations_1ec40468-bf27-4b8b-a627-2e89cddfaebc', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='1ec40468-bf27-4b8b-a627-2e89cddfaebc'")
implement(id = 'strange_wid_enumerations_1fed2a14-25a6-4c27-99e6-5874ccb8609a', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='1fed2a14-25a6-4c27-99e6-5874ccb8609a'")
implement(id = 'strange_wid_enumerations_201e52da-62b7-47b1-806b-559d4141c47c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='201e52da-62b7-47b1-806b-559d4141c47c'")
implement(id = 'strange_wid_enumerations_20b3c53e-16a7-47d0-9154-c5c14af727e4', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='20b3c53e-16a7-47d0-9154-c5c14af727e4'")
implement(id = 'strange_wid_enumerations_221fa5c8-3067-438e-a39d-335c6c52b6d6', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='221fa5c8-3067-438e-a39d-335c6c52b6d6'")
implement(id = 'strange_wid_enumerations_224ec614-739e-4eda-9332-12f709f55b87', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='224ec614-739e-4eda-9332-12f709f55b87'")
implement(id = 'strange_wid_enumerations_2336d62c-5e00-4c19-8a10-8ace82b87465', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='2336d62c-5e00-4c19-8a10-8ace82b87465'")
implement(id = 'strange_wid_enumerations_23d9e5b2-c9e9-4f08-bf01-6e4195a41b1f', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='23d9e5b2-c9e9-4f08-bf01-6e4195a41b1f'")
implement(id = 'strange_wid_enumerations_23e31f3d-1012-47bf-9ea6-b89d75273710', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='23e31f3d-1012-47bf-9ea6-b89d75273710'")
implement(id = 'strange_wid_enumerations_24af7096-7401-434c-9569-5cdb507c25b9', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='24af7096-7401-434c-9569-5cdb507c25b9'")
implement(id = 'strange_wid_enumerations_24ed96fb-478d-4a64-9660-37c302832abc', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='24ed96fb-478d-4a64-9660-37c302832abc'")
implement(id = 'strange_wid_enumerations_262e6ad6-f3eb-41ee-bb1d-33614f07a9d3', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='262e6ad6-f3eb-41ee-bb1d-33614f07a9d3'")
implement(id = 'strange_wid_enumerations_272d55c6-789b-4416-a00c-513625a761f7', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='272d55c6-789b-4416-a00c-513625a761f7'")
implement(id = 'strange_wid_enumerations_27424771-7613-4a0e-8f8b-70101d3b3a85', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='27424771-7613-4a0e-8f8b-70101d3b3a85'")
implement(id = 'strange_wid_enumerations_28532fd4-6e08-417a-be3a-470d440fca6d', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='28532fd4-6e08-417a-be3a-470d440fca6d'")
implement(id = 'strange_wid_enumerations_2892e18f-e3ea-4a14-829a-a58c81015cb2', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='2892e18f-e3ea-4a14-829a-a58c81015cb2'")
implement(id = 'strange_wid_enumerations_28d729ba-c640-4907-aa79-b30ebbe2c44c', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='28d729ba-c640-4907-aa79-b30ebbe2c44c'")
implement(id = 'strange_wid_enumerations_2ab85d08-7b94-469d-b42d-17d2ef55aec1', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='2ab85d08-7b94-469d-b42d-17d2ef55aec1'")
implement(id = 'strange_wid_enumerations_2b29ae80-51d7-4cdb-adac-9ef9fc238736', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='2b29ae80-51d7-4cdb-adac-9ef9fc238736'")
implement(id = 'strange_wid_enumerations_2c3660da-2594-46a6-a026-d12a8cbca244', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='2c3660da-2594-46a6-a026-d12a8cbca244'")
implement(id = 'strange_wid_enumerations_2cb3a3b7-c9d8-4ea4-ae6e-1d412c6c6848', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='2cb3a3b7-c9d8-4ea4-ae6e-1d412c6c6848'")
implement(id = 'strange_wid_enumerations_2d327bb3-aa41-490a-9113-1e1923a99571', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='2d327bb3-aa41-490a-9113-1e1923a99571'")
implement(id = 'strange_wid_enumerations_2d684bc2-3d19-47ae-8a55-e3bde3375419', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='2d684bc2-3d19-47ae-8a55-e3bde3375419'")
implement(id = 'strange_wid_enumerations_2d686d77-ae35-4cb6-822a-9a4bb34cb37d', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='2d686d77-ae35-4cb6-822a-9a4bb34cb37d'")
implement(id = 'strange_wid_enumerations_2d6dbb8e-6f11-4f9e-83ba-60b75da3722a', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='2d6dbb8e-6f11-4f9e-83ba-60b75da3722a'")
implement(id = 'strange_wid_enumerations_2f756ccb-afb9-4536-9267-56b0080acb86', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='2f756ccb-afb9-4536-9267-56b0080acb86'")
implement(id = 'strange_wid_enumerations_2fba4a96-55e1-426a-8219-8df3b86507c0', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='2fba4a96-55e1-426a-8219-8df3b86507c0'")
implement(id = 'strange_wid_enumerations_3000b788-a08d-4485-9333-955803f03f19', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='3000b788-a08d-4485-9333-955803f03f19'")
implement(id = 'strange_wid_enumerations_30f0daf3-3b8c-4457-82e9-6e3249814591', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='30f0daf3-3b8c-4457-82e9-6e3249814591'")
implement(id = 'strange_wid_enumerations_315547cf-ac7b-4a7e-abf1-11f11ecbe321', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='315547cf-ac7b-4a7e-abf1-11f11ecbe321'")
implement(id = 'strange_wid_enumerations_32646f62-a186-44b3-9a17-8615376f0bad', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='32646f62-a186-44b3-9a17-8615376f0bad'")
implement(id = 'strange_wid_enumerations_3291d294-a6e5-46d9-a464-717bb9fea7a0', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='3291d294-a6e5-46d9-a464-717bb9fea7a0'")
implement(id = 'strange_wid_enumerations_329cf78d-ac18-4eb8-8c50-6cda09f0f130', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='329cf78d-ac18-4eb8-8c50-6cda09f0f130'")
implement(id = 'strange_wid_enumerations_32e75de5-345e-4ebf-8c2a-1912cabb1d6e', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='32e75de5-345e-4ebf-8c2a-1912cabb1d6e'")
implement(id = 'strange_wid_enumerations_336f4705-866a-436b-9c37-9f7fdb58154f', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='336f4705-866a-436b-9c37-9f7fdb58154f'")
implement(id = 'strange_wid_enumerations_344d4d36-5c6a-478a-bc6a-26fd2ada8c47', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='344d4d36-5c6a-478a-bc6a-26fd2ada8c47'")
implement(id = 'strange_wid_enumerations_345b8210-c378-4c64-828d-79bc0fca516e', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='345b8210-c378-4c64-828d-79bc0fca516e'")
implement(id = 'strange_wid_enumerations_3548c7e0-c015-4637-ad92-c52ce1e309fe', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='3548c7e0-c015-4637-ad92-c52ce1e309fe'")
implement(id = 'strange_wid_enumerations_354da14b-470d-4bfc-b408-0a15db1a0aaa', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='354da14b-470d-4bfc-b408-0a15db1a0aaa'")
implement(id = 'strange_wid_enumerations_358efaec-712a-4087-bbf4-53fdf93d8d65', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='358efaec-712a-4087-bbf4-53fdf93d8d65'")
implement(id = 'strange_wid_enumerations_361f9b43-f451-4258-a54e-c9b61ca8d70f', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='361f9b43-f451-4258-a54e-c9b61ca8d70f'")
implement(id = 'strange_wid_enumerations_362379cf-5eb4-47e5-a470-519e0f5ae2cd', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='362379cf-5eb4-47e5-a470-519e0f5ae2cd'")
implement(id = 'strange_wid_enumerations_367c9a2c-6b50-49d6-a84f-54a6e294c449', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='367c9a2c-6b50-49d6-a84f-54a6e294c449'")
implement(id = 'strange_wid_enumerations_36bbc8e5-8592-4172-9ebb-fda7510bb08e', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='36bbc8e5-8592-4172-9ebb-fda7510bb08e'")
implement(id = 'strange_wid_enumerations_36ec2115-7f1f-44e5-93fa-84566f06797a', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='36ec2115-7f1f-44e5-93fa-84566f06797a'")
implement(id = 'strange_wid_enumerations_370229ac-d471-4a6c-8b19-4688ac171355', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='370229ac-d471-4a6c-8b19-4688ac171355'")
implement(id = 'strange_wid_enumerations_373e25ec-0d32-4d0a-b19c-2ebb827223c7', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='373e25ec-0d32-4d0a-b19c-2ebb827223c7'")
implement(id = 'strange_wid_enumerations_374d1144-80e8-437d-ad49-05e879b8b9f6', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='374d1144-80e8-437d-ad49-05e879b8b9f6'")
implement(id = 'strange_wid_enumerations_37da5b8c-ec9e-48d1-814a-5a991208ca67', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='37da5b8c-ec9e-48d1-814a-5a991208ca67'")
implement(id = 'strange_wid_enumerations_3836a5c1-7b9f-4b71-8eee-c9ac98537522', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='3836a5c1-7b9f-4b71-8eee-c9ac98537522'")
implement(id = 'strange_wid_enumerations_384e17a7-f7d6-4785-bc05-50ef5577332d', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='384e17a7-f7d6-4785-bc05-50ef5577332d'")
implement(id = 'strange_wid_enumerations_387dd485-6691-4438-abfb-8e168305e685', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='387dd485-6691-4438-abfb-8e168305e685'")
implement(id = 'strange_wid_enumerations_39992f5f-fff1-4304-9052-363a859b11b8', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='39992f5f-fff1-4304-9052-363a859b11b8'")
implement(id = 'strange_wid_enumerations_39c44192-a579-4a7e-92fe-cb453d7c29ab', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='39c44192-a579-4a7e-92fe-cb453d7c29ab'")
implement(id = 'strange_wid_enumerations_3a0af05f-61b5-4cde-8ad6-c4d96b7961d9', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='3a0af05f-61b5-4cde-8ad6-c4d96b7961d9'")
implement(id = 'strange_wid_enumerations_3aeab43d-9f80-42c2-9c16-8c1b0dd581ab', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='3aeab43d-9f80-42c2-9c16-8c1b0dd581ab'")
implement(id = 'strange_wid_enumerations_3b5c68bf-696c-4828-8752-c2c494e0fbea', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='3836a5c1-7b9f-4b71-8eee-c9ac98537522'")
implement(id = 'strange_wid_enumerations_3b62e948-ce87-495d-b05b-8f8a6ed2c61c', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='3b62e948-ce87-495d-b05b-8f8a6ed2c61c'")
implement(id = 'strange_wid_enumerations_02bcd479-2f2f-4b1f-add8-a436fdb32246', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='02bcd479-2f2f-4b1f-add8-a436fdb32246'")
implement(id = 'strange_wid_enumerations_2046c45c-ed0a-4b1e-a9dd-f2b56adaa3f9', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='2046c45c-ed0a-4b1e-a9dd-f2b56adaa3f9'")
implement(id = 'strange_wid_enumerations_2281904d-9315-4192-ae86-d1812b573216', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='2281904d-9315-4192-ae86-d1812b573216'")
implement(id = 'strange_wid_enumerations_86461ca1-0bdf-4ca7-881b-0b2856264efb', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='86461ca1-0bdf-4ca7-881b-0b2856264efb'")
implement(id = 'strange_wid_enumerations_88ecec2e-a255-4454-98fa-f1c5ac602868', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='88ecec2e-a255-4454-98fa-f1c5ac602868'")
implement(id = 'strange_wid_enumerations_aefedc58-7092-476f-9067-49317ab8d54b', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='aefedc58-7092-476f-9067-49317ab8d54b'")
implement(id = 'strange_wid_enumerations_b02d06a7-d9b2-463d-b04c-a73ca8d4e640', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='b02d06a7-d9b2-463d-b04c-a73ca8d4e640'")
implement(id = 'strange_wid_enumerations_b6ac9f21-c6f4-4123-b388-9a43d838dc2d', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='b6ac9f21-c6f4-4123-b388-9a43d838dc2d'")
implement(id = 'strange_wid_enumerations_b7ca0095-97d3-4aac-beb2-19919b7518fb', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='b7ca0095-97d3-4aac-beb2-19919b7518fb'")
implement(id = 'strange_wid_enumerations_ba4dfa4f-2915-4d9d-9886-840d4128e990', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='ba4dfa4f-2915-4d9d-9886-840d4128e990'")
implement(id = 'strange_wid_enumerations_c2815eba-96ce-498b-8d0c-2a42b74e4e5b', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='c2815eba-96ce-498b-8d0c-2a42b74e4e5b'")
implement(id = 'strange_wid_enumerations_cbbe7784-4df4-4398-9354-fb28d3880a72', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='cbbe7784-4df4-4398-9354-fb28d3880a72'")
implement(id = 'strange_wid_enumerations_d5f2eab2-4ec5-43c3-8b1b-001a499cc0d5', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='d5f2eab2-4ec5-43c3-8b1b-001a499cc0d5'")
implement(id = 'strange_wid_enumerations_e46e18aa-032b-4343-852b-c5286ec05c22', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e46e18aa-032b-4343-852b-c5286ec05c22'")
implement(id = 'strange_wid_enumerations_f7047d86-68ed-400d-9b86-00ca682fb4b1', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='f7047d86-68ed-400d-9b86-00ca682fb4b1'")
implement(id = 'strange_wid_enumerations_f78762ed-2ebe-4cfb-8d61-70d33359642c', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='f78762ed-2ebe-4cfb-8d61-70d33359642c'")
implement(id = 'missing_wid_enumerations_08fe0d70-9d80-4b0f-8804-25f0dfdf60ec', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='08fe0d70-9d80-4b0f-8804-25f0dfdf60ec'")
implement(id = 'missing_wid_enumerations_09995ca6-4a1c-4ba9-881c-08e41bf561aa', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='09995ca6-4a1c-4ba9-881c-08e41bf561aa'")
implement(id = 'missing_wid_enumerations_0e1bb8bc-396b-4c4b-839b-f4e170c3ada4', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='0e1bb8bc-396b-4c4b-839b-f4e170c3ada4'")
implement(id = 'missing_wid_enumerations_18198621-c23c-4c92-889b-68a45855b494', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='18198621-c23c-4c92-889b-68a45855b494'")
implement(id = 'missing_wid_enumerations_23c69d4a-d1e8-4f7e-a277-eb11dffe99a1', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='23c69d4a-d1e8-4f7e-a277-eb11dffe99a1'")
implement(id = 'missing_wid_enumerations_23df4ecd-f5cd-4c1d-b49f-f671410291a7', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='23df4ecd-f5cd-4c1d-b49f-f671410291a7'")
implement(id = 'missing_wid_enumerations_2b2725ee-e970-4039-84b2-96e28f7b029c', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='2b2725ee-e970-4039-84b2-96e28f7b029c'")
implement(id = 'missing_wid_enumerations_31c80c75-4729-4d8a-ad26-7eddbf1e52ad', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='31c80c75-4729-4d8a-ad26-7eddbf1e52ad'")
implement(id = 'missing_wid_enumerations_3613f05a-306e-4901-af64-a8b3a0cfe2df', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='3613f05a-306e-4901-af64-a8b3a0cfe2df'")
implement(id = 'missing_wid_enumerations_3b8eaac0-9b91-4297-9256-0d6df95b2600', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='3b8eaac0-9b91-4297-9256-0d6df95b2600'")
implement(id = 'missing_wid_enumerations_3f3a3cd0-a845-4abb-8261-063fe4295985', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='3f3a3cd0-a845-4abb-8261-063fe4295985'")
implement(id = 'missing_wid_enumerations_45ccde8f-1714-416e-b458-42aa0b8119b0', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='45ccde8f-1714-416e-b458-42aa0b8119b0'")
implement(id = 'missing_wid_enumerations_47ff755a-3cda-42b1-8b38-31419b1d2199', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='47ff755a-3cda-42b1-8b38-31419b1d2199'")
implement(id = 'missing_wid_enumerations_4a5b9b45-8a87-4415-b8eb-3122551eed85', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='4a5b9b45-8a87-4415-b8eb-3122551eed85'")
implement(id = 'missing_wid_enumerations_4e0ab97e-0e39-4cf0-9367-2660720e7683', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='4e0ab97e-0e39-4cf0-9367-2660720e7683'")
implement(id = 'missing_wid_enumerations_50fd0f85-2856-47d3-a7de-f2a8edab0c3a', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='50fd0f85-2856-47d3-a7de-f2a8edab0c3a'")
implement(id = 'missing_wid_enumerations_52f94259-6fb3-4d1c-bf2e-53483bcde9a4', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='52f94259-6fb3-4d1c-bf2e-53483bcde9a4'")
implement(id = 'missing_wid_enumerations_585fb243-102c-4c60-aa97-481e975f81ad', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='585fb243-102c-4c60-aa97-481e975f81ad'")
implement(id = 'missing_wid_enumerations_5b926ad4-1c2b-4d03-9912-bb236bd0b6ae', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='5b926ad4-1c2b-4d03-9912-bb236bd0b6ae'")
implement(id = 'missing_wid_enumerations_60db13a4-e1a1-40a5-9694-030ca855240b', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='60db13a4-e1a1-40a5-9694-030ca855240b'")
implement(id = 'missing_wid_enumerations_65186a1a-e1fc-425c-b813-0f23030b9a01', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='65186a1a-e1fc-425c-b813-0f23030b9a01'")
implement(id = 'missing_wid_enumerations_6681fa32-71ea-49cb-8197-9a0eab4e4a94', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='6681fa32-71ea-49cb-8197-9a0eab4e4a94'")
implement(id = 'missing_wid_enumerations_6731a976-a5c1-4c5c-a13c-2def2df81504', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6731a976-a5c1-4c5c-a13c-2def2df81504'")
implement(id = 'missing_wid_enumerations_681f07ea-d579-408d-ae07-d2640b2c35ee', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='681f07ea-d579-408d-ae07-d2640b2c35ee'")
implement(id = 'missing_wid_enumerations_6c5dbf05-1a78-4b6b-a544-4444bef51e21', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6c5dbf05-1a78-4b6b-a544-4444bef51e21'")
implement(id = 'missing_wid_enumerations_6f3a75bb-95a7-4ff3-9a4e-3603ea7b4e4d', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='6f3a75bb-95a7-4ff3-9a4e-3603ea7b4e4d'")
implement(id = 'missing_wid_enumerations_70353f33-b6e1-4d13-8663-514b6a3001be', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='70353f33-b6e1-4d13-8663-514b6a3001be'")
implement(id = 'missing_wid_enumerations_73c5cf53-b465-496e-a1de-6b2a63b98f78', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='73c5cf53-b465-496e-a1de-6b2a63b98f78'")
implement(id = 'missing_wid_enumerations_777dcd2d-3c5d-4066-a54c-37aaaeaeb20b', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='777dcd2d-3c5d-4066-a54c-37aaaeaeb20b'")
implement(id = 'missing_wid_enumerations_77fb3d62-4e4c-49ea-8d57-cb9fa0267dad', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='77fb3d62-4e4c-49ea-8d57-cb9fa0267dad'")
implement(id = 'missing_wid_enumerations_781e5bb5-d9c0-43ae-87eb-d43c1bc0cfbc', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='781e5bb5-d9c0-43ae-87eb-d43c1bc0cfbc'")
implement(id = 'missing_wid_enumerations_7d6e3c7f-9077-4b9c-885f-035c0ed94469', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='7d6e3c7f-9077-4b9c-885f-035c0ed94469'")
implement(id = 'missing_wid_enumerations_7f0bc25c-ea0d-4032-bee1-4e30ba221259', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='7f0bc25c-ea0d-4032-bee1-4e30ba221259'")
implement(id = 'missing_wid_enumerations_80e059f8-1c72-4659-9682-816b4c3a4594', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='80e059f8-1c72-4659-9682-816b4c3a4594'")
implement(id = 'missing_wid_enumerations_818e7f8f-09b0-47be-8fcd-cc042fd4e96f', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='818e7f8f-09b0-47be-8fcd-cc042fd4e96f'")
implement(id = 'missing_wid_enumerations_837969ba-2bec-4970-881d-765f9e0f9c33', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='837969ba-2bec-4970-881d-765f9e0f9c33'")
implement(id = 'missing_wid_enumerations_8536c3d8-92d6-4247-ace0-76470aa454ac', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='8536c3d8-92d6-4247-ace0-76470aa454ac'")
implement(id = 'missing_wid_enumerations_885ea0c5-30b3-42a5-a9dd-3a82a7c85f5a', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='885ea0c5-30b3-42a5-a9dd-3a82a7c85f5a'")
implement(id = 'missing_wid_enumerations_891a7166-5cfb-4762-b503-501796d570b1', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='891a7166-5cfb-4762-b503-501796d570b1'")
implement(id = 'missing_wid_enumerations_8a005d4a-5186-475c-9426-82a0628b2292', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='8a005d4a-5186-475c-9426-82a0628b2292'")
implement(id = 'missing_wid_enumerations_8cf1311d-2f4d-46a3-9a3e-178b0265d36f', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='8cf1311d-2f4d-46a3-9a3e-178b0265d36f'")
implement(id = 'missing_wid_enumerations_8d93c459-b461-493e-98b2-01deef25a8a6', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='8d93c459-b461-493e-98b2-01deef25a8a6'")
implement(id = 'missing_wid_enumerations_9175fcdc-43a9-4f3a-9a6c-a9bd8ddab4a0', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9175fcdc-43a9-4f3a-9a6c-a9bd8ddab4a0'")
implement(id = 'missing_wid_enumerations_9251ea3f-2e06-488e-b82e-87038212925a', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='9251ea3f-2e06-488e-b82e-87038212925a'")
implement(id = 'missing_wid_enumerations_95654412-a145-44ef-8796-8eb473130a44', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='95654412-a145-44ef-8796-8eb473130a44'")
implement(id = 'missing_wid_enumerations_98868192-3544-4929-9cf1-ed008f384987', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='98868192-3544-4929-9cf1-ed008f384987'")
implement(id = 'missing_wid_enumerations_9a093c8e-a4ac-4e20-b637-ba0c5556669c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='9a093c8e-a4ac-4e20-b637-ba0c5556669c'")
implement(id = 'missing_wid_enumerations_9bae0f70-9195-405d-a8e4-d8161c8284e5', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='9bae0f70-9195-405d-a8e4-d8161c8284e5'")
implement(id = 'missing_wid_enumerations_a14e95cd-d040-42b7-9736-77f2967203f1', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='a14e95cd-d040-42b7-9736-77f2967203f1'")
implement(id = 'missing_wid_enumerations_a82302d4-346a-41fe-8735-bfc41830d7f9', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='a82302d4-346a-41fe-8735-bfc41830d7f9'")
implement(id = 'missing_wid_enumerations_aefc2e2b-e3fd-4142-bdd4-3625a19c7823', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='aefc2e2b-e3fd-4142-bdd4-3625a19c7823'")
implement(id = 'missing_wid_enumerations_afd8f5c5-29e7-448e-b545-a5129d5a7da1', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='afd8f5c5-29e7-448e-b545-a5129d5a7da1'")
implement(id = 'missing_wid_enumerations_b4110e98-3355-4ea1-9d25-a4d11de59b4f', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='b4110e98-3355-4ea1-9d25-a4d11de59b4f'")
implement(id = 'missing_wid_enumerations_bc9b9d51-b567-4ec7-a80a-21610467a067', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='bc9b9d51-b567-4ec7-a80a-21610467a067'")
implement(id = 'missing_wid_enumerations_c0f6a6e5-6888-4486-abd4-c71ba691acf2', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='c0f6a6e5-6888-4486-abd4-c71ba691acf2'")
implement(id = 'missing_wid_enumerations_c8d8d6e1-64f7-40a7-989d-f4bc262e7725', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='c8d8d6e1-64f7-40a7-989d-f4bc262e7725'")
implement(id = 'missing_wid_enumerations_da139887-e1ba-4112-a743-b28fc3538909', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='da139887-e1ba-4112-a743-b28fc3538909'")
implement(id = 'missing_wid_enumerations_dbd676c7-0504-4750-b5f3-67a02b89d994', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='dbd676c7-0504-4750-b5f3-67a02b89d994'")
implement(id = 'missing_wid_enumerations_dc554b8b-3ebf-48db-96bc-af70a6c5e9ad', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='dc554b8b-3ebf-48db-96bc-af70a6c5e9ad'")
implement(id = 'missing_wid_enumerations_dea1672f-76c9-4e80-a6cc-9abb50773e94', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='dea1672f-76c9-4e80-a6cc-9abb50773e94'")
implement(id = 'missing_wid_enumerations_e058e359-5509-4d20-8e3f-037e81077c1f', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e058e359-5509-4d20-8e3f-037e81077c1f'")
implement(id = 'missing_wid_enumerations_e76b4fae-1159-4723-bf2a-40e74fed5623', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e76b4fae-1159-4723-bf2a-40e74fed5623'")
implement(id = 'missing_wid_enumerations_ec656c69-9960-4c3b-b6e6-e02e204b9456', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='ec656c69-9960-4c3b-b6e6-e02e204b9456'")
implement(id = 'missing_wid_enumerations_ee952891-7c81-4d1b-a44a-f259f9887de0', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='ee952891-7c81-4d1b-a44a-f259f9887de0'")
implement(id = 'missing_wid_enumerations_faeb2a8f-b8bc-4cba-ae9d-375564b8ebd4', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='faeb2a8f-b8bc-4cba-ae9d-375564b8ebd4'")
implement(id = 'strange_wid_enumerations_3c1cd1ea-0a75-4b5b-8c98-ccf78dc72f94', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='3c1cd1ea-0a75-4b5b-8c98-ccf78dc72f94'")
implement(id = 'strange_wid_enumerations_3cae4b5a-63a9-4eff-a067-fc6086fc8d72', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='3cae4b5a-63a9-4eff-a067-fc6086fc8d72'")
implement(id = 'strange_wid_enumerations_3d52d4d8-650e-4344-8b59-b1c1fcd59363', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='3d52d4d8-650e-4344-8b59-b1c1fcd59363'")
implement(id = 'strange_wid_enumerations_3ea6834e-ddcc-4271-827d-a5ec15196bf9', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='3ea6834e-ddcc-4271-827d-a5ec15196bf9'")
implement(id = 'strange_wid_enumerations_3f14ac77-2c15-46f4-8615-32cef9432f6f', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='3f14ac77-2c15-46f4-8615-32cef9432f6f'")
implement(id = 'strange_wid_enumerations_404ffb53-29cc-48e9-9d38-219acd0a96e0', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='404ffb53-29cc-48e9-9d38-219acd0a96e0'")
implement(id = 'strange_wid_enumerations_414cb286-9b5e-4ad6-bebe-0fdf0e8b118a', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='414cb286-9b5e-4ad6-bebe-0fdf0e8b118a'")
implement(id = 'strange_wid_enumerations_417d3a24-8c37-4e19-a950-7a89726fd753', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='417d3a24-8c37-4e19-a950-7a89726fd753'")
implement(id = 'strange_wid_enumerations_425c5b98-402c-4e3f-96a3-489072efe817', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='425c5b98-402c-4e3f-96a3-489072efe817'")
implement(id = 'strange_wid_enumerations_428f4892-4dc3-4cec-8423-db7ee6e8d1e7', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='428f4892-4dc3-4cec-8423-db7ee6e8d1e7'")
implement(id = 'strange_wid_6d308e9c-48c1-4c7c-b492-e26e4de45a6e', query = "UPDATE clean_minicensus_main SET wid='418' WHERE instance_id='6d308e9c-48c1-4c7c-b492-e26e4de45a6e'")
implement(id = 'strange_wid_enumerations_027c6f94-811e-4220-9006-89be5752b4de', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='027c6f94-811e-4220-9006-89be5752b4de'")
implement(id = 'strange_wid_enumerations_0321e8e7-6d06-4de7-a964-bbbb11081cdf', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='0321e8e7-6d06-4de7-a964-bbbb11081cdf'")
implement(id = 'strange_wid_enumerations_03f3fd17-41b7-4d06-9f92-6d3e199657c7', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='03f3fd17-41b7-4d06-9f92-6d3e199657c7'")
implement(id = 'strange_wid_enumerations_0404b1dc-c88b-42a8-8ff2-de91b5829c9f', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='0404b1dc-c88b-42a8-8ff2-de91b5829c9f'")
implement(id = 'strange_wid_enumerations_05b6a363-bdcc-4ebd-a075-7b6d444823d0', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='05b6a363-bdcc-4ebd-a075-7b6d444823d0'")
implement(id = 'strange_wid_enumerations_05f80b5e-da6d-4047-924d-900e0b2c11ff', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='05f80b5e-da6d-4047-924d-900e0b2c11ff'")
implement(id = 'strange_wid_enumerations_0c6e2dd1-2699-4b20-abac-7d0491fd60f6', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='0c6e2dd1-2699-4b20-abac-7d0491fd60f6'")
implement(id = 'strange_wid_enumerations_0ded8ad6-667e-4b0b-a3c5-4f72102d209f', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='0ded8ad6-667e-4b0b-a3c5-4f72102d209f'")
implement(id = 'strange_wid_enumerations_0e5c00a9-f943-49a2-ad0d-9e973733bef6', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='0e5c00a9-f943-49a2-ad0d-9e973733bef6'")
implement(id = 'strange_wid_enumerations_0eb2b946-a129-410a-a832-15ea972b6bbd', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='0eb2b946-a129-410a-a832-15ea972b6bbd'")
implement(id = 'strange_wid_enumerations_0f9cd31a-acc6-4d24-a68d-74cc62842a27', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='0f9cd31a-acc6-4d24-a68d-74cc62842a27'")
implement(id = 'strange_wid_enumerations_1001e8f2-cdc3-4fc7-aab1-c81b9a240ad9', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='1001e8f2-cdc3-4fc7-aab1-c81b9a240ad9'")
implement(id = 'strange_wid_enumerations_1067f4cf-8031-4b2a-a968-aeab875cb495', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='1067f4cf-8031-4b2a-a968-aeab875cb495'")
implement(id = 'strange_wid_enumerations_1432f21a-fa3a-4fb6-920f-7b3f4091f859', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='1432f21a-fa3a-4fb6-920f-7b3f4091f859'")
implement(id = 'strange_wid_enumerations_14bda237-671a-4f5a-bcd7-d67e04d61f41', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='14bda237-671a-4f5a-bcd7-d67e04d61f41'")
implement(id = 'strange_wid_enumerations_15d30c82-7acf-42a2-b120-0edf98aba9e0', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='15d30c82-7acf-42a2-b120-0edf98aba9e0'")
implement(id = 'strange_wid_enumerations_17ddf86b-078e-4852-bf87-67cb3424bc01', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='17ddf86b-078e-4852-bf87-67cb3424bc01'")
implement(id = 'strange_wid_enumerations_194ce55c-792d-4dfc-91da-f1d5ea2becfc', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='194ce55c-792d-4dfc-91da-f1d5ea2becfc'")
implement(id = 'strange_wid_enumerations_19cc2372-7e45-4636-85dc-363f013686bf', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='19cc2372-7e45-4636-85dc-363f013686bf'")
implement(id = 'strange_wid_enumerations_19f5e721-5943-4b78-9552-d509190f2693', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='19f5e721-5943-4b78-9552-d509190f2693'")
implement(id = 'strange_wid_enumerations_1c91a73b-33f5-44e3-bbf1-4fda48962611', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='1c91a73b-33f5-44e3-bbf1-4fda48962611'")
implement(id = 'strange_wid_enumerations_1db57d60-e78e-4f23-90c5-ee82d0ea5b57', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='1db57d60-e78e-4f23-90c5-ee82d0ea5b57'")
implement(id = 'strange_wid_enumerations_1f2a1c20-7f31-4174-a1f3-9844204d72e7', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='1f2a1c20-7f31-4174-a1f3-9844204d72e7'")
implement(id = 'strange_wid_enumerations_20f996bc-6511-47db-95ab-dc8f1f152d7c', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='20f996bc-6511-47db-95ab-dc8f1f152d7c'")
implement(id = 'strange_wid_enumerations_21f2c496-4c31-431f-a298-894b60c28ca4', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='21f2c496-4c31-431f-a298-894b60c28ca4'")
implement(id = 'strange_wid_enumerations_221f2169-8527-409a-8986-7bc721eed0b1', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='221f2169-8527-409a-8986-7bc721eed0b1'")
implement(id = 'strange_wid_enumerations_223f7996-30b1-4e82-a830-3c8025880124', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='223f7996-30b1-4e82-a830-3c8025880124'")
implement(id = 'strange_wid_enumerations_22794598-450e-4f2a-81c8-7e7272eb5e32', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='22794598-450e-4f2a-81c8-7e7272eb5e32'")
implement(id = 'strange_wid_enumerations_24d398c0-8659-4fb9-a301-c12b3a1b5c45', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='24d398c0-8659-4fb9-a301-c12b3a1b5c45'")
implement(id = 'strange_wid_enumerations_263b7f90-6da6-406d-8748-7afe552390c7', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='263b7f90-6da6-406d-8748-7afe552390c7'")
implement(id = 'strange_wid_enumerations_27cd6db5-f978-4de7-b00d-c1b3b0702778', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='27cd6db5-f978-4de7-b00d-c1b3b0702778'")
implement(id = 'strange_wid_enumerations_281dfb29-d9f2-4bce-98fe-01e10ae5b0c5', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='281dfb29-d9f2-4bce-98fe-01e10ae5b0c5'")
implement(id = 'strange_wid_enumerations_2b55da7a-dfb2-4304-b345-aabd5abce226', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='2b55da7a-dfb2-4304-b345-aabd5abce226'")
implement(id = 'strange_wid_enumerations_2d4e3afc-c68f-4b3f-ad1f-60664617a4e7', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='2d4e3afc-c68f-4b3f-ad1f-60664617a4e7'")
implement(id = 'strange_wid_enumerations_2d9dc57f-9f0e-4494-912a-fbfb614d847f', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='2d9dc57f-9f0e-4494-912a-fbfb614d847f'")
implement(id = 'strange_wid_enumerations_2f051c49-f057-4b3f-8259-b5867e05b4b9', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='2f051c49-f057-4b3f-8259-b5867e05b4b9'")
implement(id = 'strange_wid_enumerations_2f8b76e2-b926-432e-9dbc-71da302a5366', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='2f8b76e2-b926-432e-9dbc-71da302a5366'")
implement(id = 'strange_wid_enumerations_2f91d5e6-3d1e-43c5-9dde-e7161d9652fa', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='2f91d5e6-3d1e-43c5-9dde-e7161d9652fa'")
implement(id = 'strange_wid_enumerations_342c880e-881a-471e-b19b-0ed742d341b8', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='342c880e-881a-471e-b19b-0ed742d341b8'")
implement(id = 'strange_wid_enumerations_3470acea-5019-435e-8bcc-48bf178db6dc', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='3470acea-5019-435e-8bcc-48bf178db6dc'")
implement(id = 'strange_wid_enumerations_36318228-764a-4962-bc5e-176f7fe9a3f1', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='36318228-764a-4962-bc5e-176f7fe9a3f1'")
implement(id = 'strange_wid_enumerations_36ccda5f-f830-4d0b-8ecb-f0aaada44d35', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='36ccda5f-f830-4d0b-8ecb-f0aaada44d35'")
implement(id = 'strange_wid_enumerations_3be8b613-ace7-4d38-b8a6-c7f7a3e588bd', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='3be8b613-ace7-4d38-b8a6-c7f7a3e588bd'")
implement(id = 'strange_wid_enumerations_3becab1e-9a47-4e77-b051-5dba64f71c12', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='3becab1e-9a47-4e77-b051-5dba64f71c12'")
implement(id = 'strange_wid_enumerations_3d501d38-c566-4071-87ce-60478f0eb1cd', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='3d501d38-c566-4071-87ce-60478f0eb1cd'")
implement(id = 'strange_wid_enumerations_3dd4abb4-ad84-44bb-8206-06af242eff8b', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='3dd4abb4-ad84-44bb-8206-06af242eff8b'")
implement(id = 'strange_wid_enumerations_3ff9f1de-12b1-48f9-8500-a9ab63c063ab', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='3ff9f1de-12b1-48f9-8500-a9ab63c063ab'")
implement(id = 'strange_wid_enumerations_4027038c-8fc1-4b2c-a95c-59af8d51c803', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='4027038c-8fc1-4b2c-a95c-59af8d51c803'")
implement(id = 'strange_wid_enumerations_4240bbe9-31c6-421f-bd3a-7e73a19a16e0', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='4240bbe9-31c6-421f-bd3a-7e73a19a16e0'")
implement(id = 'strange_wid_enumerations_43966ca0-ece3-4b9a-83cd-9aed79bf1302', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='43966ca0-ece3-4b9a-83cd-9aed79bf1302'")
implement(id = 'strange_wid_enumerations_43b28afe-e148-404b-98dd-4ae8b8612dbe', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='43b28afe-e148-404b-98dd-4ae8b8612dbe'")
implement(id = 'strange_wid_enumerations_449f41d3-6ef4-4a1d-b9b8-be75795c6b94', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='449f41d3-6ef4-4a1d-b9b8-be75795c6b94'")
implement(id = 'strange_wid_enumerations_459419c6-136f-4798-9517-4c7d8348e2cc', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='459419c6-136f-4798-9517-4c7d8348e2cc'")
implement(id = 'strange_wid_enumerations_47bcde17-d848-421d-8d73-ec43d42f0f23', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='47bcde17-d848-421d-8d73-ec43d42f0f23'")
implement(id = 'strange_wid_enumerations_4958e53d-fd19-4908-9722-5c5549267840', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='4958e53d-fd19-4908-9722-5c5549267840'")
implement(id = 'strange_wid_enumerations_496bde60-6f11-4dd0-9d71-a04558b31096', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='496bde60-6f11-4dd0-9d71-a04558b31096'")
implement(id = 'strange_wid_enumerations_49d729a3-74b8-48e1-a729-f48be7df4aa3', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='49d729a3-74b8-48e1-a729-f48be7df4aa3'")
implement(id = 'strange_wid_enumerations_4ace1cc1-5c26-4f65-a017-e7ee97962100', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='4ace1cc1-5c26-4f65-a017-e7ee97962100'")
implement(id = 'strange_wid_enumerations_4b979997-eb9d-46f4-a907-269ff3ef4a3d', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='4b979997-eb9d-46f4-a907-269ff3ef4a3d'")
implement(id = 'strange_wid_enumerations_4b9d74e4-c2e2-4a13-bc3d-efe5a4471105', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='4b9d74e4-c2e2-4a13-bc3d-efe5a4471105'")
implement(id = 'strange_wid_enumerations_4c4907b7-9dd5-4169-b51e-37f7b8f0e471', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='4c4907b7-9dd5-4169-b51e-37f7b8f0e471'")
implement(id = 'strange_wid_enumerations_4c93c678-4ffb-4dfd-bf48-77d81ed5bb76', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='4c93c678-4ffb-4dfd-bf48-77d81ed5bb76'")
implement(id = 'strange_wid_enumerations_50381b98-6f82-4f27-88a0-9caace146f15', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='50381b98-6f82-4f27-88a0-9caace146f15'")
implement(id = 'strange_wid_enumerations_512993ba-bc02-4d56-bd8d-db292daca3cd', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='512993ba-bc02-4d56-bd8d-db292daca3cd'")
implement(id = 'strange_wid_enumerations_51fd6ad4-2c9f-41cb-ad60-a2053917d88e', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='51fd6ad4-2c9f-41cb-ad60-a2053917d88e'")
implement(id = 'strange_wid_enumerations_529502f5-365e-4da3-8571-23a07b4aa763', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='529502f5-365e-4da3-8571-23a07b4aa763'")
implement(id = 'strange_wid_enumerations_579f7188-25ef-4988-8085-8b1c944ceeec', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='579f7188-25ef-4988-8085-8b1c944ceeec'")
implement(id = 'strange_wid_enumerations_57a70883-ecdd-47dc-ac06-c5265d03ee3f', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='57a70883-ecdd-47dc-ac06-c5265d03ee3f'")
implement(id = 'strange_wid_enumerations_5980b1f8-3783-4708-a5a0-bc4eaa707f19', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='5980b1f8-3783-4708-a5a0-bc4eaa707f19'")
implement(id = 'strange_wid_enumerations_59b0fdeb-d165-4f85-b142-bf800a9b8472', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='59b0fdeb-d165-4f85-b142-bf800a9b8472'")
implement(id = 'strange_wid_enumerations_5cd5199d-6c48-41b9-8601-32f306f15820', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='5cd5199d-6c48-41b9-8601-32f306f15820'")
implement(id = 'strange_wid_enumerations_5d859fdc-4fb4-4c31-9b44-bfdaeef517c5', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='5d859fdc-4fb4-4c31-9b44-bfdaeef517c5'")
implement(id = 'strange_wid_enumerations_5e47e387-bb8e-4851-8864-03556a301414', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='5e47e387-bb8e-4851-8864-03556a301414'")
implement(id = 'strange_wid_enumerations_5ee6c7af-f7c1-4591-a3e1-9cc4ca9cd6f2', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='5ee6c7af-f7c1-4591-a3e1-9cc4ca9cd6f2'")
implement(id = 'strange_wid_enumerations_60c61825-4ffe-4e25-9bf5-9d918f6de353', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='60c61825-4ffe-4e25-9bf5-9d918f6de353'")
implement(id = 'strange_wid_enumerations_61353dde-017f-40b6-a4ad-ab1126a25978', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='61353dde-017f-40b6-a4ad-ab1126a25978'")
implement(id = 'strange_wid_enumerations_64324b3e-107d-44c4-8832-8046c800786c', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='64324b3e-107d-44c4-8832-8046c800786c'")
implement(id = 'strange_wid_enumerations_657c99fd-869d-4dba-a04c-3c5321bc60a7', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='657c99fd-869d-4dba-a04c-3c5321bc60a7'")
implement(id = 'strange_wid_enumerations_662b5a44-a54e-4b4e-8026-fe0bf4aa4d3a', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='662b5a44-a54e-4b4e-8026-fe0bf4aa4d3a'")
implement(id = 'strange_wid_enumerations_67408e9c-2847-434e-9c7c-c5cf8c10ddf2', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='67408e9c-2847-434e-9c7c-c5cf8c10ddf2'")
implement(id = 'strange_wid_enumerations_68036492-3913-4d99-adf9-00992cc60bb8', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='68036492-3913-4d99-adf9-00992cc60bb8'")
implement(id = 'strange_wid_enumerations_689a49d8-f682-47fc-9654-7b77ccf01771', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='689a49d8-f682-47fc-9654-7b77ccf01771'")
implement(id = 'strange_wid_enumerations_6bd1ab0a-5597-4b56-88df-60793d16774e', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6bd1ab0a-5597-4b56-88df-60793d16774e'")
implement(id = 'strange_wid_enumerations_6ecd7f3e-e069-44c4-9b99-bbd238810d8d', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6ecd7f3e-e069-44c4-9b99-bbd238810d8d'")
implement(id = 'strange_wid_enumerations_6ee0c52d-7670-418e-8256-51ca10804147', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6ee0c52d-7670-418e-8256-51ca10804147'")
implement(id = 'strange_wid_enumerations_6f144ee2-4f0a-4b5d-8986-a34b80e81db6', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='6f144ee2-4f0a-4b5d-8986-a34b80e81db6'")
implement(id = 'strange_wid_enumerations_715bd2d6-7f4c-4f9f-af9a-72af5ef8a556', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='715bd2d6-7f4c-4f9f-af9a-72af5ef8a556'")
implement(id = 'strange_wid_enumerations_72760ace-53ce-4d3f-a456-acabe4801bbe', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='72760ace-53ce-4d3f-a456-acabe4801bbe'")
implement(id = 'strange_wid_enumerations_72a7b79f-1bb3-4812-b314-f7d0db3270a8', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='72a7b79f-1bb3-4812-b314-f7d0db3270a8'")
implement(id = 'strange_wid_enumerations_73d58c5e-c787-42b4-9f96-a86c53aa04a5', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='73d58c5e-c787-42b4-9f96-a86c53aa04a5'")
implement(id = 'strange_wid_enumerations_783f0102-dacc-4d98-855c-495857c574f9', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='783f0102-dacc-4d98-855c-495857c574f9'")
implement(id = 'strange_wid_enumerations_785cd3df-79bf-4887-a757-66dc76281665', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='785cd3df-79bf-4887-a757-66dc76281665'")
implement(id = 'strange_wid_enumerations_789ebeb8-2034-41a0-87e3-957fcbb65222', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='789ebeb8-2034-41a0-87e3-957fcbb65222'")
implement(id = 'strange_wid_enumerations_7dbff94c-c6d9-45cb-b86b-5809a9ec0d9c', query = "UPDATE clean_enumerations SET wid='442' WHERE instance_id='7dbff94c-c6d9-45cb-b86b-5809a9ec0d9c'")
implement(id = 'strange_wid_enumerations_7f696905-c8cf-4b70-a7e1-2c1c09f1fa2b', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='7f696905-c8cf-4b70-a7e1-2c1c09f1fa2b'")
implement(id = 'strange_wid_enumerations_7f8c6676-05bf-4505-a4f9-4ed7d95c6fea', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='7f8c6676-05bf-4505-a4f9-4ed7d95c6fea'")
implement(id = 'strange_wid_enumerations_80975b47-ccc7-4b69-8ff8-7d1c4344408e', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='80975b47-ccc7-4b69-8ff8-7d1c4344408e'")
implement(id = 'strange_wid_enumerations_81bea8ed-ed17-4327-a101-090000727bf6', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='81bea8ed-ed17-4327-a101-090000727bf6'")
implement(id = 'strange_wid_enumerations_834c9f14-6bab-439a-ad36-1a133ccaac00', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='834c9f14-6bab-439a-ad36-1a133ccaac00'")
implement(id = 'strange_wid_enumerations_85de8611-0278-48c9-aea7-f58e9e5c3063', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='85de8611-0278-48c9-aea7-f58e9e5c3063'")
implement(id = 'strange_wid_enumerations_875c03dd-4553-4865-8976-07a22b0244b6', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='875c03dd-4553-4865-8976-07a22b0244b6'")
implement(id = 'strange_wid_enumerations_88518e2b-0365-4a12-a2ac-cbd453be39e8', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='88518e2b-0365-4a12-a2ac-cbd453be39e8'")
implement(id = 'strange_wid_enumerations_89cd7cd6-b693-4ff1-874b-60a39e37951e', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='89cd7cd6-b693-4ff1-874b-60a39e37951e'")
implement(id = 'strange_wid_enumerations_8a9d9d23-85ef-4b83-aa1b-6f729ea822d2', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='8a9d9d23-85ef-4b83-aa1b-6f729ea822d2'")
implement(id = 'strange_wid_enumerations_8b271c21-f98d-4eae-9868-f3e0f9998a9a', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='8b271c21-f98d-4eae-9868-f3e0f9998a9a'")
implement(id = 'strange_wid_enumerations_8dbb1b7a-d481-4fee-a815-0b17ad6e58c8', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='8dbb1b7a-d481-4fee-a815-0b17ad6e58c8'")
implement(id = 'strange_wid_enumerations_8edeb2e7-eeb6-47b9-a898-e93d631b8a01', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='8edeb2e7-eeb6-47b9-a898-e93d631b8a01'")
implement(id = 'strange_wid_enumerations_8f82cf10-9311-4309-81bf-675c88ccaa14', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='8f82cf10-9311-4309-81bf-675c88ccaa14'")
implement(id = 'strange_wid_enumerations_8fdae6a0-33bb-4b82-aa9b-83e340bf58b9', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='8fdae6a0-33bb-4b82-aa9b-83e340bf58b9'")
implement(id = 'strange_wid_enumerations_9034ab64-6140-4954-b5dd-a1c6fcde279b', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='9034ab64-6140-4954-b5dd-a1c6fcde279b'")
implement(id = 'strange_wid_enumerations_907f8e78-3ad2-4062-b860-83861763a89e', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='907f8e78-3ad2-4062-b860-83861763a89e'")
implement(id = 'strange_wid_enumerations_91217d64-e5f6-42cd-b932-81a453ea6171', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='91217d64-e5f6-42cd-b932-81a453ea6171'")
implement(id = 'strange_wid_enumerations_9214ae80-b797-4e54-ad6d-2c7a4da11842', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9214ae80-b797-4e54-ad6d-2c7a4da11842'")
implement(id = 'strange_wid_enumerations_926d5412-d4b9-41d2-9ebb-8e3a72a34088', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='926d5412-d4b9-41d2-9ebb-8e3a72a34088'")
implement(id = 'strange_wid_enumerations_92b0aae0-e1ac-4296-9d66-95b577956c99', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='92b0aae0-e1ac-4296-9d66-95b577956c99'")
implement(id = 'strange_wid_enumerations_977f49be-5d8e-4748-9bf1-771de63c61e5', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='977f49be-5d8e-4748-9bf1-771de63c61e5'")
implement(id = 'strange_wid_enumerations_98598048-1eac-42f4-9ab0-74be46bc0497', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='98598048-1eac-42f4-9ab0-74be46bc0497'")
implement(id = 'strange_wid_enumerations_9a1d1148-7d5a-43a3-8b61-421cba0ecdf6', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9a1d1148-7d5a-43a3-8b61-421cba0ecdf6'")
implement(id = 'strange_wid_enumerations_9af5515f-2aab-4421-a6c2-e39ec3f7bbfa', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='9af5515f-2aab-4421-a6c2-e39ec3f7bbfa'")
implement(id = 'strange_wid_enumerations_9b1ef4b7-f24e-4c4d-a8db-baafef405f37', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='9b1ef4b7-f24e-4c4d-a8db-baafef405f37'")
implement(id = 'strange_wid_enumerations_9b8421b9-00be-4baa-9cec-8d9b305d3422', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='9b8421b9-00be-4baa-9cec-8d9b305d3422'")
implement(id = 'strange_wid_enumerations_9efa99db-887d-4512-89a7-395592f7713c', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='9efa99db-887d-4512-89a7-395592f7713c'")
implement(id = 'strange_wid_enumerations_a08d829f-b3cd-4c99-8071-bcdb977b50e9', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='a08d829f-b3cd-4c99-8071-bcdb977b50e9'")
implement(id = 'strange_wid_enumerations_a0cc5a71-b8f0-4f67-a9c5-cbe93a78895a', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='a0cc5a71-b8f0-4f67-a9c5-cbe93a78895a'")
implement(id = 'strange_wid_enumerations_a2160881-85ad-4ece-8e26-c2a2e917b393', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='a2160881-85ad-4ece-8e26-c2a2e917b393'")
implement(id = 'strange_wid_enumerations_a3e13380-7761-4240-8ee2-8ece6fe3e26a', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='a3e13380-7761-4240-8ee2-8ece6fe3e26a'")
implement(id = 'strange_wid_enumerations_a410306c-f169-4f30-8291-67a219b12370', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='a410306c-f169-4f30-8291-67a219b12370'")
implement(id = 'strange_wid_enumerations_a70bac77-a590-48df-8e2b-b83c0fb617f3', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='a70bac77-a590-48df-8e2b-b83c0fb617f3'")
implement(id = 'strange_wid_enumerations_a7e68483-c251-425f-b6e0-c252cff2fac7', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='a7e68483-c251-425f-b6e0-c252cff2fac7'")
implement(id = 'strange_wid_enumerations_a9a51440-7d08-4e9e-9b66-0384d2e1529c', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='a9a51440-7d08-4e9e-9b66-0384d2e1529c'")
implement(id = 'strange_wid_enumerations_aa6260cb-3995-44f8-bb44-7a6ad7da3ff0', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='aa6260cb-3995-44f8-bb44-7a6ad7da3ff0'")
implement(id = 'strange_wid_enumerations_abdb980f-4f01-45a5-a385-6ff2f3557c48', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='abdb980f-4f01-45a5-a385-6ff2f3557c48'")
implement(id = 'strange_wid_enumerations_afb93c8f-d8d7-40d2-92fc-b36877c7ec2c', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='afb93c8f-d8d7-40d2-92fc-b36877c7ec2c'")
implement(id = 'strange_wid_enumerations_b0b28828-a256-426f-9119-837f68d71fc0', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='b0b28828-a256-426f-9119-837f68d71fc0'")
implement(id = 'strange_wid_enumerations_b0e5dfef-5267-47f0-b64a-6c9c14c7b025', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='b0e5dfef-5267-47f0-b64a-6c9c14c7b025'")
implement(id = 'strange_wid_enumerations_b3b0da09-d4ea-41f3-9846-e30b5cc4d7ac', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='b3b0da09-d4ea-41f3-9846-e30b5cc4d7ac'")
implement(id = 'strange_wid_enumerations_b3bc9f84-6b92-4de9-b8b5-24f7157839d3', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='b3bc9f84-6b92-4de9-b8b5-24f7157839d3'")
implement(id = 'strange_wid_enumerations_b3dcaf8c-9294-4e14-9b26-743369e92438', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='b3dcaf8c-9294-4e14-9b26-743369e92438'")
implement(id = 'strange_wid_enumerations_b45710c1-3286-4a67-b25f-7027393464a3', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='b45710c1-3286-4a67-b25f-7027393464a3'")
implement(id = 'strange_wid_enumerations_b4e7b9d4-92fb-48a9-92c5-94b644a44c3f', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='b4e7b9d4-92fb-48a9-92c5-94b644a44c3f'")
implement(id = 'strange_wid_enumerations_b7152b77-d588-43d1-bc05-cec2f0a6157a', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='b7152b77-d588-43d1-bc05-cec2f0a6157a'")
implement(id = 'strange_wid_enumerations_bc830c90-5916-4b29-bf40-d9568ebee35d', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='bc830c90-5916-4b29-bf40-d9568ebee35d'")
implement(id = 'strange_wid_enumerations_bd34f85c-513d-4a03-9913-9782263d4d4e', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='bd34f85c-513d-4a03-9913-9782263d4d4e'")
implement(id = 'strange_wid_enumerations_bdbf62e0-032f-452c-869b-3724d3dfe0b5', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='bdbf62e0-032f-452c-869b-3724d3dfe0b5'")
implement(id = 'strange_wid_enumerations_c085241b-b3b5-46e8-8dbd-1456d59eb5ae', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='c085241b-b3b5-46e8-8dbd-1456d59eb5ae'")
implement(id = 'strange_wid_enumerations_c0dbfa77-379f-4167-9190-5db3ea003432', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='c0dbfa77-379f-4167-9190-5db3ea003432'")
implement(id = 'strange_wid_enumerations_c175bcce-7dbd-4919-bb35-00bfe1569412', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='c175bcce-7dbd-4919-bb35-00bfe1569412'")
implement(id = 'strange_wid_enumerations_c39e5234-519d-4bdf-a254-ec7660e6cef5', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='c39e5234-519d-4bdf-a254-ec7660e6cef5'")
implement(id = 'strange_wid_enumerations_c498ba72-e482-461c-a125-b0f06551d537', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='c498ba72-e482-461c-a125-b0f06551d537'")
implement(id = 'strange_wid_enumerations_c5296e18-31a7-4d77-beff-cae089c9c046', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='c5296e18-31a7-4d77-beff-cae089c9c046'")
implement(id = 'strange_wid_enumerations_c783d189-5930-48c1-a119-d2e61ca3dd41', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='c783d189-5930-48c1-a119-d2e61ca3dd41'")
implement(id = 'strange_wid_enumerations_c886674a-45f9-4a1c-91ff-9f308400055a', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='c886674a-45f9-4a1c-91ff-9f308400055a'")
implement(id = 'strange_wid_enumerations_c9da49b3-21e3-4470-97c7-93245d05d809', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='c9da49b3-21e3-4470-97c7-93245d05d809'")
implement(id = 'strange_wid_enumerations_cb96e9e8-4515-41bf-a733-40bad0a19735', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='cb96e9e8-4515-41bf-a733-40bad0a19735'")
implement(id = 'strange_wid_enumerations_ce3c2bd7-a838-4d37-ba82-6dd911fd63be', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='ce3c2bd7-a838-4d37-ba82-6dd911fd63be'")
implement(id = 'strange_wid_enumerations_cf804b52-61d5-4ae2-a517-d6d8b7815e92', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='cf804b52-61d5-4ae2-a517-d6d8b7815e92'")
implement(id = 'strange_wid_enumerations_d34db697-4c05-4667-a594-c51d881f751d', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='d34db697-4c05-4667-a594-c51d881f751d'")
implement(id = 'strange_wid_enumerations_d365a5e3-de4c-47e0-9507-1d26b8a12fa3', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='d365a5e3-de4c-47e0-9507-1d26b8a12fa3'")
implement(id = 'strange_wid_enumerations_d4b739b5-3ca2-4c71-b062-9dcd1875afe4', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='d4b739b5-3ca2-4c71-b062-9dcd1875afe4'")
implement(id = 'strange_wid_enumerations_d658d49c-6836-4d11-b5bd-bcbb23b4c7f1', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='d658d49c-6836-4d11-b5bd-bcbb23b4c7f1'")
implement(id = 'strange_wid_enumerations_d6592cde-5240-47cc-91c3-72d0870e1d9c', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='d6592cde-5240-47cc-91c3-72d0870e1d9c'")
implement(id = 'strange_wid_enumerations_d8bcbccd-dec6-4519-aedd-fc8def499004', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='d8bcbccd-dec6-4519-aedd-fc8def499004'")
implement(id = 'strange_wid_enumerations_d96cc88b-0ae1-49a7-8b04-c38b1e36138f', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='d96cc88b-0ae1-49a7-8b04-c38b1e36138f'")
implement(id = 'strange_wid_enumerations_dc17c278-7a81-4deb-883b-7d2bdb5f396d', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='dc17c278-7a81-4deb-883b-7d2bdb5f396d'")
implement(id = 'strange_wid_enumerations_dc30c18c-fe89-42d8-b879-877dd910ed98', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='dc30c18c-fe89-42d8-b879-877dd910ed98'")
implement(id = 'strange_wid_enumerations_dc5e7d64-66a7-4bae-b903-4be0d99e4d1c', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='dc5e7d64-66a7-4bae-b903-4be0d99e4d1c'")
implement(id = 'strange_wid_enumerations_dcff020e-a6f6-451d-ad3a-e0b659ee38c8', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='dcff020e-a6f6-451d-ad3a-e0b659ee38c8'")
implement(id = 'strange_wid_enumerations_e01df30e-e5a1-4d06-bf80-8deb1c0a061b', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='e01df30e-e5a1-4d06-bf80-8deb1c0a061b'")
implement(id = 'strange_wid_enumerations_e09d5da0-0fa0-4d12-9c53-699282611d60', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='e09d5da0-0fa0-4d12-9c53-699282611d60'")
implement(id = 'strange_wid_enumerations_e17aa220-cdd0-49ba-9f5c-83364460ae16', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e17aa220-cdd0-49ba-9f5c-83364460ae16'")
implement(id = 'strange_wid_enumerations_e2de998d-ee36-49b9-a10a-131d6b9611db', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='e2de998d-ee36-49b9-a10a-131d6b9611db'")
implement(id = 'strange_wid_enumerations_e52419e4-efb8-4c94-adc1-6814009767a2', query = "UPDATE clean_enumerations SET wid='433' WHERE instance_id='e52419e4-efb8-4c94-adc1-6814009767a2'")
implement(id = 'strange_wid_enumerations_e6816896-b671-4979-8473-e8a71f746ad9', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e6816896-b671-4979-8473-e8a71f746ad9'")
implement(id = 'strange_wid_enumerations_e8480758-73f5-4309-9010-3f2e6fcd72de', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='e8480758-73f5-4309-9010-3f2e6fcd72de'")
implement(id = 'strange_wid_enumerations_eb6f16fc-52fa-47c9-bf6f-61c0950fc3a4', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='eb6f16fc-52fa-47c9-bf6f-61c0950fc3a4'")
implement(id = 'strange_wid_enumerations_ed00f9de-b917-4241-b8c5-e05be413d030', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='ed00f9de-b917-4241-b8c5-e05be413d030'")
implement(id = 'strange_wid_enumerations_f0429d2f-79c9-4936-875d-5957b013d684', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='f0429d2f-79c9-4936-875d-5957b013d684'")
implement(id = 'strange_wid_enumerations_f11d2cf1-bfdd-445d-b2a5-c681245c4e9a', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='f11d2cf1-bfdd-445d-b2a5-c681245c4e9a'")
implement(id = 'strange_wid_enumerations_f128b15a-0deb-49a7-a5a2-fc90d01e7cb5', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='f128b15a-0deb-49a7-a5a2-fc90d01e7cb5'")
implement(id = 'strange_wid_enumerations_f1dbf0ba-c877-4a54-b5db-2ba9a60f856f', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='f1dbf0ba-c877-4a54-b5db-2ba9a60f856f'")
implement(id = 'strange_wid_enumerations_f252e9b1-cb6a-4061-8954-45c524c14459', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='f252e9b1-cb6a-4061-8954-45c524c14459'")
implement(id = 'strange_wid_enumerations_f377de1e-727e-4714-8e0f-54e3dd85440f', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='f377de1e-727e-4714-8e0f-54e3dd85440f'")
implement(id = 'strange_wid_enumerations_f517b88e-2be5-4c81-a0ab-ae586d3fc718', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='f517b88e-2be5-4c81-a0ab-ae586d3fc718'")
implement(id = 'strange_wid_enumerations_f6e1dd55-a6b7-4585-bbe2-47c5d7add542', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='f6e1dd55-a6b7-4585-bbe2-47c5d7add542'")
implement(id = 'strange_wid_enumerations_f9e3177f-0681-48b7-990b-96a3defb7598', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='f9e3177f-0681-48b7-990b-96a3defb7598'")
implement(id = 'strange_wid_enumerations_fc7d3dc7-27e4-433a-b65b-57ebb1f87e31', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='fc7d3dc7-27e4-433a-b65b-57ebb1f87e31'")
implement(id = 'strange_wid_enumerations_fd2ba2a6-0d1c-40fd-b375-110271d19852', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='fd2ba2a6-0d1c-40fd-b375-110271d19852'")
implement(id = 'strange_wid_enumerations_fe2acd0b-0a54-4ffc-9150-9ae45e76dc68', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='fe2acd0b-0a54-4ffc-9150-9ae45e76dc68'")
implement(id = 'strange_wid_enumerations_feb3e03c-039a-43e0-a92a-8da4653c4141', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='feb3e03c-039a-43e0-a92a-8da4653c4141'")
implement(id = 'strange_wid_enumerations_429f8162-fbc1-419c-bf2a-a2ee7127f195', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='429f8162-fbc1-419c-bf2a-a2ee7127f195'")
implement(id = 'strange_wid_enumerations_433f520b-f5f8-4c7d-97fa-89b5f2743679', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='433f520b-f5f8-4c7d-97fa-89b5f2743679'")
implement(id = 'strange_wid_enumerations_44fbb43c-0883-48c5-9058-fc75ebcf21ea', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='44fbb43c-0883-48c5-9058-fc75ebcf21ea'")
implement(id = 'strange_wid_enumerations_45227317-cab7-42bd-994b-4f6c038e8936', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='45227317-cab7-42bd-994b-4f6c038e8936'")
implement(id = 'strange_wid_enumerations_455ca77f-6e2e-46d8-af59-de9de317adad', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='455ca77f-6e2e-46d8-af59-de9de317adad'")
implement(id = 'strange_wid_enumerations_45e540be-d36f-4cdd-bace-cb6cc514185d', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='45e540be-d36f-4cdd-bace-cb6cc514185d'")
implement(id = 'strange_wid_enumerations_469efad9-f38c-4309-8fe1-0afbf4d5ff42', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='469efad9-f38c-4309-8fe1-0afbf4d5ff42'")
implement(id = 'strange_wid_enumerations_46b661e5-2bef-46aa-ad37-8ad6284f055a', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='46b661e5-2bef-46aa-ad37-8ad6284f055a'")
implement(id = 'strange_wid_enumerations_46fd2764-c3d1-42a6-ab5c-bbe908443058', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='46fd2764-c3d1-42a6-ab5c-bbe908443058'")
implement(id = 'strange_wid_enumerations_472687c1-24d6-4bb6-a3d5-e7ba35347d8b', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='472687c1-24d6-4bb6-a3d5-e7ba35347d8b'")
implement(id = 'strange_wid_enumerations_4899d363-7423-4535-9ad1-9532eaa7d2d5', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='4899d363-7423-4535-9ad1-9532eaa7d2d5'")
implement(id = 'strange_wid_enumerations_48b355ec-e35a-4bb6-9c34-a179a4fc8833', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='48b355ec-e35a-4bb6-9c34-a179a4fc8833'")
implement(id = 'strange_wid_enumerations_49706481-f872-45f4-b4de-dd5c1bc50c30', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='49706481-f872-45f4-b4de-dd5c1bc50c30'")
implement(id = 'strange_wid_enumerations_4978347c-96bd-4fd3-b4e5-6282ca25c2a8', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='4978347c-96bd-4fd3-b4e5-6282ca25c2a8'")
implement(id = 'strange_wid_enumerations_49e21a3c-3f61-4308-b2d9-8241b3eb09fd', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='49e21a3c-3f61-4308-b2d9-8241b3eb09fd'")
implement(id = 'strange_wid_enumerations_4a7ec965-cae8-4f73-b865-6d313ef89077', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='4a7ec965-cae8-4f73-b865-6d313ef89077'")
implement(id = 'strange_wid_enumerations_4bc7dbe3-468f-495a-a163-2ad216bd953b', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='4bc7dbe3-468f-495a-a163-2ad216bd953b'")
implement(id = 'strange_wid_enumerations_4f185272-bf13-4831-b8cd-bcd2b6c23455', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='4f185272-bf13-4831-b8cd-bcd2b6c23455'")
implement(id = 'strange_wid_enumerations_4f1aaf2d-0c64-428c-bef0-b60444f28a44', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='4f1aaf2d-0c64-428c-bef0-b60444f28a44'")
implement(id = 'strange_wid_enumerations_4f4c106e-7530-4a81-b3e6-55d8f1b48dd9', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='4f4c106e-7530-4a81-b3e6-55d8f1b48dd9'")
implement(id = 'strange_wid_enumerations_5005ac3d-1282-499c-9cf1-375bb23e4449', query = "UPDATE clean_enumerations SET wid='383' WHERE instance_id='5005ac3d-1282-499c-9cf1-375bb23e4449'")
implement(id = 'strange_wid_enumerations_50c85b43-b4f6-4533-baae-f1347170b308', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='50c85b43-b4f6-4533-baae-f1347170b308'")
implement(id = 'strange_wid_enumerations_50deb336-99fc-46f0-94b4-2182057f6b76', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='50deb336-99fc-46f0-94b4-2182057f6b76'")

implement(id = 'strange_wid_enumerations_01826bbc-f519-4ea4-a58e-23053d27c6f0', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='01826bbc-f519-4ea4-a58e-23053d27c6f0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_1312ee21-7c1f-4b68-84c8-ab58d88b8449', query = "UPDATE clean_enumerations SET wid='373' WHERE instance_id='1312ee21-7c1f-4b68-84c8-ab58d88b8449'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_50e0070c-1dc1-4564-81ff-3e50b031f994', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='50e0070c-1dc1-4564-81ff-3e50b031f994'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5168cf5e-f012-446a-a32b-ac1d997065bc', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='5168cf5e-f012-446a-a32b-ac1d997065bc'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_52658e27-5955-49e3-ab57-1b6590adc138', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='52658e27-5955-49e3-ab57-1b6590adc138'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_53a8af08-10cf-488f-aeea-e3c61cf17a98', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='53a8af08-10cf-488f-aeea-e3c61cf17a98'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_53dea47f-bf86-4e41-97b2-f7193d75076b', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='53dea47f-bf86-4e41-97b2-f7193d75076b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_543e6e28-0719-4ff0-a7f5-d1622ddd5b34', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='543e6e28-0719-4ff0-a7f5-d1622ddd5b34'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_547139cd-4f3e-4b48-98f2-c537b796cc47', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='547139cd-4f3e-4b48-98f2-c537b796cc47'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_54c77064-b0a3-462c-a8e2-403abd2893b5', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='54c77064-b0a3-462c-a8e2-403abd2893b5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_551e6ef9-3e74-4404-b8ad-9ab621900b7d', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='551e6ef9-3e74-4404-b8ad-9ab621900b7d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_55635769-a689-4e83-87a2-1591a111e81b', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='55635769-a689-4e83-87a2-1591a111e81b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_55fcdd8f-5273-4f18-b199-77663b046500', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='55fcdd8f-5273-4f18-b199-77663b046500'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_56547492-3682-4215-b2ae-c7bac12d89c9', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='56547492-3682-4215-b2ae-c7bac12d89c9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_56b8c93d-ac8c-4cb7-9c6f-288a50ccebac', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='56b8c93d-ac8c-4cb7-9c6f-288a50ccebac'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_56da06b0-4aea-427f-ab00-9e135295eb35', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='56da06b0-4aea-427f-ab00-9e135295eb35'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_57722f3e-3d1b-4cfa-a065-a6044901c641', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='57722f3e-3d1b-4cfa-a065-a6044901c641'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_587c8307-ac2f-4c45-8aef-3fb3fd8445f8', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='587c8307-ac2f-4c45-8aef-3fb3fd8445f8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_59284a9c-b989-4516-9a01-e8cb4da28090', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='59284a9c-b989-4516-9a01-e8cb4da28090'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_593525d7-6d08-43b8-afa8-1951041c87a5', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='593525d7-6d08-43b8-afa8-1951041c87a5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_598c768c-732e-4daf-b99f-9939a3ca5449', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='598c768c-732e-4daf-b99f-9939a3ca5449'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_59a5254c-8645-43ca-83ba-584849a04d41', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='59a5254c-8645-43ca-83ba-584849a04d41'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5a127420-bf98-49d4-ad1e-faa4fc3385b5', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='5a127420-bf98-49d4-ad1e-faa4fc3385b5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5bbd1592-9050-4d72-ada1-0fdea77fd36c', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='5bbd1592-9050-4d72-ada1-0fdea77fd36c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5bf76c0f-f02b-495f-a719-e596a269e3bb', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='5bf76c0f-f02b-495f-a719-e596a269e3bb'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5c99e39a-166c-482c-b725-13ae71910aa2', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='5c99e39a-166c-482c-b725-13ae71910aa2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5d8baec0-2f90-4c59-8bae-633b77e86edd', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='5d8baec0-2f90-4c59-8bae-633b77e86edd'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5daa37a4-f3f3-4cfa-8204-fc1a27aedf2c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='5daa37a4-f3f3-4cfa-8204-fc1a27aedf2c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5feeed48-c86f-4774-b5d2-75cd2a9d0fa1', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='5feeed48-c86f-4774-b5d2-75cd2a9d0fa1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6011bf7f-10a4-498e-b48f-0fc5b37365f3', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='6011bf7f-10a4-498e-b48f-0fc5b37365f3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6177901a-05bd-40ac-8cfc-d8440abb8ca9', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='6177901a-05bd-40ac-8cfc-d8440abb8ca9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_621e9123-f60a-4ce1-ab3d-9cc27b244ff4', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='621e9123-f60a-4ce1-ab3d-9cc27b244ff4'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6399c14b-246b-401d-a631-4f9fc1ee340a', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6399c14b-246b-401d-a631-4f9fc1ee340a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_63db3f83-e890-41cb-b68c-6861df88613b', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='63db3f83-e890-41cb-b68c-6861df88613b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_63ee9e0c-911d-4433-8f3d-277a4f8ae6c9', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='63ee9e0c-911d-4433-8f3d-277a4f8ae6c9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_64366cd7-e14e-40bd-ad6c-d86bf716e8b5', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='64366cd7-e14e-40bd-ad6c-d86bf716e8b5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_64775351-78e0-4ce9-a10a-b3b5b4d40908', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='64775351-78e0-4ce9-a10a-b3b5b4d40908'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_65340da2-ea89-43cc-863b-107e455fdb7f', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='65340da2-ea89-43cc-863b-107e455fdb7f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_65746382-cd51-424d-83c6-6455ddd2add3', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='65746382-cd51-424d-83c6-6455ddd2add3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_664aa739-cdc0-4f29-b418-bb07ac2368ab', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='664aa739-cdc0-4f29-b418-bb07ac2368ab'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_678eedec-bce4-4440-96c7-79017ccd60d3', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='678eedec-bce4-4440-96c7-79017ccd60d3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6a63e926-f320-4789-bfb4-2ee5f4d0cc30', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='6a63e926-f320-4789-bfb4-2ee5f4d0cc30'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6a732413-2097-4a93-84b4-565361a6cfb1', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='6a732413-2097-4a93-84b4-565361a6cfb1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6a9d7203-575b-4d68-959c-da433dac201f', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6a9d7203-575b-4d68-959c-da433dac201f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6b805d98-cbcf-49a0-86d8-17afe68b19ed', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='6b805d98-cbcf-49a0-86d8-17afe68b19ed'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6d1b06ad-9930-426f-a8e7-86826eb67bd7', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6d1b06ad-9930-426f-a8e7-86826eb67bd7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6e156247-f61c-4a3b-a813-f519614880dc', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='6e156247-f61c-4a3b-a813-f519614880dc'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6efaf33a-93fb-4aeb-9134-943520d73652', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='6efaf33a-93fb-4aeb-9134-943520d73652'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_715c5ac5-c889-482f-9415-3e4bc86d87a1', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='715c5ac5-c889-482f-9415-3e4bc86d87a1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_71d4c36b-66c5-4d2c-8429-a91d05520887', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='71d4c36b-66c5-4d2c-8429-a91d05520887'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_73d7066c-2ab6-416f-946f-416bd9789f38', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='73d7066c-2ab6-416f-946f-416bd9789f38'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_741d8428-801a-49fc-ae23-b0f3af6c6589', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='741d8428-801a-49fc-ae23-b0f3af6c6589'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_74b1a36f-a292-48c3-adda-afaa9fa7f600', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='74b1a36f-a292-48c3-adda-afaa9fa7f600'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_74ced52b-a9ae-418f-b046-0706c5987017', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='74ced52b-a9ae-418f-b046-0706c5987017'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_761c3a78-4202-44a1-834d-50135042abc2', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='761c3a78-4202-44a1-834d-50135042abc2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_76ed1008-9507-45d6-8a96-3d3a1a8026a7', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='76ed1008-9507-45d6-8a96-3d3a1a8026a7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_77195815-03ce-4292-90ba-b7543e0f11f6', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='77195815-03ce-4292-90ba-b7543e0f11f6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_77f9af56-1ea2-47d7-9c36-30a46601b5f3', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='77f9af56-1ea2-47d7-9c36-30a46601b5f3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7860f0f1-caa0-4dc8-b16b-be267a1232c8', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='7860f0f1-caa0-4dc8-b16b-be267a1232c8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_79743b35-43a1-4b3f-b26c-256fab141ce0', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='79743b35-43a1-4b3f-b26c-256fab141ce0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7a0f1532-8818-4e29-bbe2-8ff893bd7a71', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='7a0f1532-8818-4e29-bbe2-8ff893bd7a71'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7a95465e-0cab-499d-9854-fd3584263a08', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='7a95465e-0cab-499d-9854-fd3584263a08'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7b1ea63d-f7fb-4f53-99e3-c2b428636a98', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='7b1ea63d-f7fb-4f53-99e3-c2b428636a98'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7b39b72e-9937-4a1e-a0db-3be541f56e03', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='7b39b72e-9937-4a1e-a0db-3be541f56e03'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7b601dcc-7eae-4ba0-bf6b-5a15807f52cf', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='7b601dcc-7eae-4ba0-bf6b-5a15807f52cf'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7bd97025-5644-4b3f-8f9f-bc556f31b477', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='7bd97025-5644-4b3f-8f9f-bc556f31b477'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7c513134-8683-40a4-ac74-a69d83401d61', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='7c513134-8683-40a4-ac74-a69d83401d61'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7d19bfe6-926d-444c-92a2-fba67f2d0f90', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='7d19bfe6-926d-444c-92a2-fba67f2d0f90'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7d52ec6a-03ce-47c0-bbfb-6c5411f5f2cd', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='7d52ec6a-03ce-47c0-bbfb-6c5411f5f2cd'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7e27f10e-7ab2-4ac3-b8fe-138efb2c0fe8', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='7e27f10e-7ab2-4ac3-b8fe-138efb2c0fe8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7e2cd911-2eee-49cc-b704-df052a73e2b6', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='7e2cd911-2eee-49cc-b704-df052a73e2b6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7fd6ca91-9ee4-484f-950d-407019dd47cf', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='7fd6ca91-9ee4-484f-950d-407019dd47cf'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_804c5d0f-54e2-47ea-8e6f-ffb5497a5eda', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='804c5d0f-54e2-47ea-8e6f-ffb5497a5eda'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_80f63cc9-2f6b-40bb-a753-a84416416a33', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='80f63cc9-2f6b-40bb-a753-a84416416a33'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_814dfbf7-00ac-489a-9e30-c2725f382ec1', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='814dfbf7-00ac-489a-9e30-c2725f382ec1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_829323cb-a1f6-4280-bb94-4c385ad08f5d', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='829323cb-a1f6-4280-bb94-4c385ad08f5d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_82a1acde-0efc-45ed-92fa-f109173f7248', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='82a1acde-0efc-45ed-92fa-f109173f7248'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_82c2594b-917f-4e52-aa43-daabeb4e4b78', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='82c2594b-917f-4e52-aa43-daabeb4e4b78'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_832ccbd9-8946-40e7-b9f9-f68d2af62cfc', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='832ccbd9-8946-40e7-b9f9-f68d2af62cfc'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8348f308-17a8-40cd-92c1-69d5c9e1f3a7', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='8348f308-17a8-40cd-92c1-69d5c9e1f3a7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_84e83c91-3b35-48e3-b418-622cf6ddfae8', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='84e83c91-3b35-48e3-b418-622cf6ddfae8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_85a11d83-f6b7-480d-ac5d-a0401ff38739', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='85a11d83-f6b7-480d-ac5d-a0401ff38739'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_85d16ce9-783d-483e-9e4a-c6784b67d17e', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='85d16ce9-783d-483e-9e4a-c6784b67d17e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_86487053-b2cf-4b2b-8a44-0f03543ea688', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='86487053-b2cf-4b2b-8a44-0f03543ea688'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_864d9630-8457-45db-b7ea-702c65046632', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='864d9630-8457-45db-b7ea-702c65046632'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_866d73d5-aa71-4bdb-a4a7-72c8e53e8127', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='866d73d5-aa71-4bdb-a4a7-72c8e53e8127'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_86775443-8c54-4de6-a1bf-2c0b829d7e54', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='86775443-8c54-4de6-a1bf-2c0b829d7e54'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8681c5b6-2f0a-48fb-b2c0-01358b220569', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='8681c5b6-2f0a-48fb-b2c0-01358b220569'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_871ac4b3-c888-4c28-96e8-b2ad54f7b25c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='871ac4b3-c888-4c28-96e8-b2ad54f7b25c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8768322a-3e8c-46ce-9a54-eba1a404cb23', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='8768322a-3e8c-46ce-9a54-eba1a404cb23'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_87d24b7d-f828-44a2-8eaa-83539cfce216', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='87d24b7d-f828-44a2-8eaa-83539cfce216'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8a5fd300-991b-4e4a-8e92-56d060eaefb9', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='8a5fd300-991b-4e4a-8e92-56d060eaefb9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8ae5c6f5-e1ff-4e8d-8a41-7c65ba88afd0', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='8ae5c6f5-e1ff-4e8d-8a41-7c65ba88afd0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8ba431d9-7524-46bd-9cc7-8b8af53070c0', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='8ba431d9-7524-46bd-9cc7-8b8af53070c0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8bb2cfaa-07e1-4f6a-974f-3f70214d4b1c', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='8bb2cfaa-07e1-4f6a-974f-3f70214d4b1c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8bcd8fae-dda7-494b-82c8-eb1c4f6a44da', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='8bcd8fae-dda7-494b-82c8-eb1c4f6a44da'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8bf28e41-f9d1-4238-8490-91ba3259633e', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='8bf28e41-f9d1-4238-8490-91ba3259633e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8d5c5642-6d3a-48d4-898d-eab7c3d673da', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='8d5c5642-6d3a-48d4-898d-eab7c3d673da'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8d808ba9-13b4-4f0c-bff6-2a701c779326', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='8d808ba9-13b4-4f0c-bff6-2a701c779326'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8e5577c9-0aac-406e-a6af-391724bc17b8', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='8e5577c9-0aac-406e-a6af-391724bc17b8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8e63bca0-2b60-48a6-ba82-32883d918dec', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='8e63bca0-2b60-48a6-ba82-32883d918dec'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8f03ba4f-fca1-4a8a-bd0e-935768b7b577', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='8f03ba4f-fca1-4a8a-bd0e-935768b7b577'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8f28e42d-ddbd-401f-bce0-45780184eafb', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='8f28e42d-ddbd-401f-bce0-45780184eafb'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8fcc5aff-65f8-4826-9be6-01552905760c', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='8fcc5aff-65f8-4826-9be6-01552905760c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8fd26300-8506-4274-b664-a9dba4304ebd', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='8fd26300-8506-4274-b664-a9dba4304ebd'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9021e1a3-7582-438c-9f5c-a1586faeac85', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='9021e1a3-7582-438c-9f5c-a1586faeac85'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_90703679-7dc7-4a1a-931b-2f06d7e42508', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='90703679-7dc7-4a1a-931b-2f06d7e42508'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_91592f38-99a8-43da-9768-e46b6f806b58', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='91592f38-99a8-43da-9768-e46b6f806b58'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9184a432-1567-4f9c-89ae-9ddb3f2aa043', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='9184a432-1567-4f9c-89ae-9ddb3f2aa043'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_91b45a48-a4a2-4476-a0a0-104fe37bc002', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='91b45a48-a4a2-4476-a0a0-104fe37bc002'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_92006471-2193-413e-8afe-be8766619525', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='92006471-2193-413e-8afe-be8766619525'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_92504a06-2330-4ad7-8cc7-41a51d72584d', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='92504a06-2330-4ad7-8cc7-41a51d72584d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_92d5e667-0a36-4023-a658-c1bcf296d208', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='92d5e667-0a36-4023-a658-c1bcf296d208'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_931b2975-90c4-460a-b1aa-5ca5ae0bd356', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='931b2975-90c4-460a-b1aa-5ca5ae0bd356'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_93a3ffa1-3b3d-47df-86c4-d1ba9ae30e6b', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='93a3ffa1-3b3d-47df-86c4-d1ba9ae30e6b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_93e871fa-2d69-4919-bc19-e5a085bb2fcc', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='93e871fa-2d69-4919-bc19-e5a085bb2fcc'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9650a1b2-fb4e-4960-94f3-f7a97db6b756', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='9650a1b2-fb4e-4960-94f3-f7a97db6b756'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_969990aa-89b5-4c59-b972-42b1c3da49b5', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='969990aa-89b5-4c59-b972-42b1c3da49b5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9711422f-1027-473a-8659-095233a6543a', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='9711422f-1027-473a-8659-095233a6543a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9836c55f-e2c8-4fb6-aa35-b5801215d00f', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='9836c55f-e2c8-4fb6-aa35-b5801215d00f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_983d213b-f927-4436-af9d-84b21a948432', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='983d213b-f927-4436-af9d-84b21a948432'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_986501c2-88de-400a-b07d-ab1c808b383c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='986501c2-88de-400a-b07d-ab1c808b383c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_98f2231f-4046-46a2-b2df-a5637d9ae81f', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='98f2231f-4046-46a2-b2df-a5637d9ae81f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_99b11b10-dc59-4517-9304-6bab982a7252', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='99b11b10-dc59-4517-9304-6bab982a7252'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9a5be8cf-0950-4d90-8100-a0240a0f443a', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9a5be8cf-0950-4d90-8100-a0240a0f443a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9abea0ec-0644-4277-92a1-aa1fdc6e236d', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9abea0ec-0644-4277-92a1-aa1fdc6e236d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9bdcd885-2ff0-4f2c-a650-4650c436c58a', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='9bdcd885-2ff0-4f2c-a650-4650c436c58a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9d2f5377-7ada-4d4c-b7a5-9bdfd5c981c2', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='9d2f5377-7ada-4d4c-b7a5-9bdfd5c981c2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9d694ca5-e04c-4f20-ac85-b554529a798c', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9d694ca5-e04c-4f20-ac85-b554529a798c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9df985a4-8d98-4647-ae16-4255faa48a7e', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9df985a4-8d98-4647-ae16-4255faa48a7e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9e35718d-36e3-42b4-aef0-efb94d472302', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9e35718d-36e3-42b4-aef0-efb94d472302'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9e6d5d6c-bd25-4c90-ba58-23af7f9cca3a', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='9e6d5d6c-bd25-4c90-ba58-23af7f9cca3a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9eb7f32d-e927-465f-be5f-7b4d9c10c552', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9eb7f32d-e927-465f-be5f-7b4d9c10c552'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9ebe26b1-1089-472b-b19a-3ae5916bc332', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='9ebe26b1-1089-472b-b19a-3ae5916bc332'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9ed7cfdc-e470-42ce-a36e-ae2b96d8bbc8', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='9ed7cfdc-e470-42ce-a36e-ae2b96d8bbc8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9ed889f3-1ab6-4e85-b43c-39417a97917c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='9ed889f3-1ab6-4e85-b43c-39417a97917c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9f1857ec-371a-4e00-8b9c-dbfb6f19b64e', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='9f1857ec-371a-4e00-8b9c-dbfb6f19b64e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a072934d-9dd8-4442-9754-62286915c412', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='a072934d-9dd8-4442-9754-62286915c412'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a1cb5b4d-e8ca-4d29-a86a-8423a2483b0b', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='a1cb5b4d-e8ca-4d29-a86a-8423a2483b0b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a33ae23f-9552-417e-afcb-843842038b0a', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='a33ae23f-9552-417e-afcb-843842038b0a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a4aa298c-d46a-46d9-973c-bce701ea0a23', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='a4aa298c-d46a-46d9-973c-bce701ea0a23'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a53185b3-8f6a-4be3-8613-27be05118b01', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='a53185b3-8f6a-4be3-8613-27be05118b01'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a5a9d487-f076-4490-a44d-330952ea7067', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='a5a9d487-f076-4490-a44d-330952ea7067'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a5b04bbb-e427-42fa-8209-72b8d36985cb', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='a5b04bbb-e427-42fa-8209-72b8d36985cb'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a6006f8b-f5da-4ada-bd0a-689cbd37dfa5', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='a6006f8b-f5da-4ada-bd0a-689cbd37dfa5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a66bbd1e-0867-42df-8d17-62fd9e2de097', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='a66bbd1e-0867-42df-8d17-62fd9e2de097'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a70c2814-5056-4b69-b165-5a6a89103b6c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='a70c2814-5056-4b69-b165-5a6a89103b6c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a70cb6a1-7d4f-44ae-8397-16ffe4d9ebcb', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='a70cb6a1-7d4f-44ae-8397-16ffe4d9ebcb'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a78494be-f79e-4332-998d-96c917994e0f', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='a78494be-f79e-4332-998d-96c917994e0f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a87e9b26-dcb4-46c9-bbea-113d11ed0f6c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='a87e9b26-dcb4-46c9-bbea-113d11ed0f6c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a8ac45b8-1e32-49ec-86df-b52e6b328aba', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='a8ac45b8-1e32-49ec-86df-b52e6b328aba'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_aa831a8f-e822-4b29-b813-260b08ae222b', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='aa831a8f-e822-4b29-b813-260b08ae222b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ab375c0f-f2b8-4016-9f32-0acaa7b1a801', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='ab375c0f-f2b8-4016-9f32-0acaa7b1a801'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ab3cfe57-29f3-44bb-8bf2-dfc02088a29c', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='ab3cfe57-29f3-44bb-8bf2-dfc02088a29c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_aba90c68-5a26-4a55-b56d-f4ff660547e0', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='aba90c68-5a26-4a55-b56d-f4ff660547e0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_abc4badf-87a3-4945-a171-7699fb32579d', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='abc4badf-87a3-4945-a171-7699fb32579d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ac36a71e-d027-4754-9e26-9d01537ce024', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='ac36a71e-d027-4754-9e26-9d01537ce024'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ac86e05f-3fa0-43d4-b35e-fb92f3e9f262', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='ac86e05f-3fa0-43d4-b35e-fb92f3e9f262'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ad1ceb67-1021-4b56-98f1-d6244f198ca2', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='ad1ceb67-1021-4b56-98f1-d6244f198ca2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ad85a089-d4ff-48c1-9a1d-e0a8ed0f1f52', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='ad85a089-d4ff-48c1-9a1d-e0a8ed0f1f52'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ae1e6165-7a7f-4ef7-816b-85e64dc6ea12', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='ae1e6165-7a7f-4ef7-816b-85e64dc6ea12'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ae4ecefb-3051-4ab1-8a34-57631d4ce5ff', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='ae4ecefb-3051-4ab1-8a34-57631d4ce5ff'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_af259274-1569-4e36-bb83-87038a2875c3', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='af259274-1569-4e36-bb83-87038a2875c3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_af2959b7-0564-4eac-9937-52a8a57d17e5', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='af2959b7-0564-4eac-9937-52a8a57d17e5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b0a7f00d-8bd7-4171-a70a-86966df1ea8f', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='b0a7f00d-8bd7-4171-a70a-86966df1ea8f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b0bab71b-179f-4135-9691-8de2c91b956a', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='b0bab71b-179f-4135-9691-8de2c91b956a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b0c72f42-8894-4269-86ef-d3e474ef404b', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='b0c72f42-8894-4269-86ef-d3e474ef404b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b19189d7-edf6-4a9a-95d4-3ff2129ff603', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='b19189d7-edf6-4a9a-95d4-3ff2129ff603'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b216bb17-f3e3-417d-a077-19d5d749184d', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='b216bb17-f3e3-417d-a077-19d5d749184d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b24a0dfb-6b48-4186-943d-482f2cb0c22b', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='b24a0dfb-6b48-4186-943d-482f2cb0c22b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b445d9ad-930d-4cab-a066-cfb41aea4996', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='b445d9ad-930d-4cab-a066-cfb41aea4996'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b527756b-89f8-4985-b97a-e0c170d6aef3', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='b527756b-89f8-4985-b97a-e0c170d6aef3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b538161a-3bcc-44c6-bd90-e2832bad72ae', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='b538161a-3bcc-44c6-bd90-e2832bad72ae'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b5bc913e-6caa-4793-a3d2-fd7b011eb05a', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='b5bc913e-6caa-4793-a3d2-fd7b011eb05a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b5ea5b0d-66e5-4774-bf2f-80a0984c9a18', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='b5ea5b0d-66e5-4774-bf2f-80a0984c9a18'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b5fa7cc3-3d60-4ee9-a0e3-c04537b0466a', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='b5fa7cc3-3d60-4ee9-a0e3-c04537b0466a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b60756d2-6982-422f-a948-79080606aafd', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='b60756d2-6982-422f-a948-79080606aafd'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b65de328-75ca-4600-8777-088fbf5cc3a4', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='b65de328-75ca-4600-8777-088fbf5cc3a4'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b6b987ab-e737-4993-9c7d-35d655a56217', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='b6b987ab-e737-4993-9c7d-35d655a56217'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b71d4991-d7a3-43fa-8d88-69a338b61912', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='b71d4991-d7a3-43fa-8d88-69a338b61912'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b7f61a6c-743c-40a6-b2ae-5d10ddb923f2', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='b7f61a6c-743c-40a6-b2ae-5d10ddb923f2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b88236e3-c8da-48c8-a5a9-bd58d84f0227', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='b88236e3-c8da-48c8-a5a9-bd58d84f0227'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b89269f5-aa83-403d-9bd2-0769a307fb14', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='b89269f5-aa83-403d-9bd2-0769a307fb14'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b8b8f735-3ecb-42b9-a6c7-a9471975de99', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='b8b8f735-3ecb-42b9-a6c7-a9471975de99'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b8c7d786-2d86-4124-9ad3-8cb72322fca4', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='b8c7d786-2d86-4124-9ad3-8cb72322fca4'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b9eb2bf4-3f8b-47aa-b0d9-f2e09614bc5e', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='b9eb2bf4-3f8b-47aa-b0d9-f2e09614bc5e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ba22b679-0dde-450a-ade4-a8056dd8a2e5', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='ba22b679-0dde-450a-ade4-a8056dd8a2e5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ba765a0c-ce9d-4040-ad81-21dfa79f507e', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='ba765a0c-ce9d-4040-ad81-21dfa79f507e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bb8205d5-fd58-47ff-9d0a-e7178834c34b', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='bb8205d5-fd58-47ff-9d0a-e7178834c34b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bbd8495e-b318-41ba-b16d-a7126c81ff6f', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='bbd8495e-b318-41ba-b16d-a7126c81ff6f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bc6ec263-93d9-478b-847e-fd59de05644e', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='bc6ec263-93d9-478b-847e-fd59de05644e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bca54588-3968-44b7-9a82-2600be9d1451', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='bca54588-3968-44b7-9a82-2600be9d1451'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_be2f9471-c21c-41b7-8ba0-6266c5b5ec33', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='be2f9471-c21c-41b7-8ba0-6266c5b5ec33'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_be3a6e8a-4c62-4468-9a7e-d3ae6d1e76c5', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='be3a6e8a-4c62-4468-9a7e-d3ae6d1e76c5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_be5e4d84-0dcb-496a-ba16-5082f7fc5325', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='be5e4d84-0dcb-496a-ba16-5082f7fc5325'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_be936d7c-fe86-4da8-953f-c4b3c36d3116', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='be936d7c-fe86-4da8-953f-c4b3c36d3116'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bfce4a4c-767b-44f5-9285-633b9c53ebc0', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='bfce4a4c-767b-44f5-9285-633b9c53ebc0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bfd9927b-82e4-4c8e-923f-d29a5d8a3bab', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='bfd9927b-82e4-4c8e-923f-d29a5d8a3bab'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bfdb0704-b6c0-4d2f-809c-66c73827c4e1', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='bfdb0704-b6c0-4d2f-809c-66c73827c4e1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bff50ed3-4fe2-4c93-ae75-3457f2ac9d54', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='bff50ed3-4fe2-4c93-ae75-3457f2ac9d54'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c02e5291-8b7d-422f-b2a9-eed0ce26cd46', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='c02e5291-8b7d-422f-b2a9-eed0ce26cd46'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c073ee99-8de4-4ea1-bb54-dde1b50a1511', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='c073ee99-8de4-4ea1-bb54-dde1b50a1511'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c1c604b5-a308-41f2-b5c0-c729e391a19c', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='c1c604b5-a308-41f2-b5c0-c729e391a19c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c26f5c9e-1854-4168-a5a5-936468a48c86', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='c26f5c9e-1854-4168-a5a5-936468a48c86'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c345875a-83eb-4dc3-a38a-061c3c8def2c', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='c345875a-83eb-4dc3-a38a-061c3c8def2c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c35fe6e4-104d-4799-8a8e-882b6970f648', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='c35fe6e4-104d-4799-8a8e-882b6970f648'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c40436df-185f-4300-9d20-fb1f2e61655e', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='c40436df-185f-4300-9d20-fb1f2e61655e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c6b4291d-35ac-4c33-b487-c2289890dd6b', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='c6b4291d-35ac-4c33-b487-c2289890dd6b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c7fdd610-30ee-4ce5-adc6-f2ee74d31bd2', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='c7fdd610-30ee-4ce5-adc6-f2ee74d31bd2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c92eda6e-e176-47b7-89a1-ffd289c6269a', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='c92eda6e-e176-47b7-89a1-ffd289c6269a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ca1819d4-c49f-4054-a985-a0e19ef59dd8', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='ca1819d4-c49f-4054-a985-a0e19ef59dd8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ca5374cf-918a-48b0-bf69-ebc12e53e4ca', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='ca5374cf-918a-48b0-bf69-ebc12e53e4ca'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cc498256-cc75-4226-93cd-17b480b948a6', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='cc498256-cc75-4226-93cd-17b480b948a6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cd33aa09-a7be-4d95-b400-6db46690fa86', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='cd33aa09-a7be-4d95-b400-6db46690fa86'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cd3d4509-1f55-491f-817a-acb97c613ab9', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='cd3d4509-1f55-491f-817a-acb97c613ab9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cda1c471-a12b-44d9-9c12-ff428186e21f', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='cda1c471-a12b-44d9-9c12-ff428186e21f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cdafe66b-da9e-4523-94c5-9b0c16a24f54', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='cdafe66b-da9e-4523-94c5-9b0c16a24f54'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cf767dbd-f19e-4cb7-9723-a2e26cc3aa42', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='cf767dbd-f19e-4cb7-9723-a2e26cc3aa42'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cffc7d08-f590-4390-a6c2-b4114cbdada6', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='cffc7d08-f590-4390-a6c2-b4114cbdada6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d0a66b0f-a591-4fb4-b334-46550a329d85', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='d0a66b0f-a591-4fb4-b334-46550a329d85'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d1c3565a-3e91-4604-bb0b-b2f0a0cc6888', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='d1c3565a-3e91-4604-bb0b-b2f0a0cc6888'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d2635da6-4d10-4154-b71f-0cba2e2d6d80', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='d2635da6-4d10-4154-b71f-0cba2e2d6d80'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d2730700-516b-4694-a9fc-60692cd7c56a', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='d2730700-516b-4694-a9fc-60692cd7c56a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d2d25f50-745c-447a-8586-e12fbfa4b225', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='d2d25f50-745c-447a-8586-e12fbfa4b225'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d46d9a69-15f9-425e-ad1c-8f3e0af21a66', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='d46d9a69-15f9-425e-ad1c-8f3e0af21a66'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d58caee8-99ad-4c4b-92d3-970433e84466', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='d58caee8-99ad-4c4b-92d3-970433e84466'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d6c94b41-cd8b-489b-abc5-7feb499c85cc', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='d6c94b41-cd8b-489b-abc5-7feb499c85cc'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d7bb4a9e-85d9-4f4b-aee7-cae991c89187', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='d7bb4a9e-85d9-4f4b-aee7-cae991c89187'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d80b478a-ebd0-4dad-8258-3ff742ee2125', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='d80b478a-ebd0-4dad-8258-3ff742ee2125'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d835c7d8-5e2d-47fd-b542-37bb661a9e34', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='d835c7d8-5e2d-47fd-b542-37bb661a9e34'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d8758ba4-363e-4f07-bce2-3a7a67538d3e', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='d8758ba4-363e-4f07-bce2-3a7a67538d3e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d89bb7f5-9d1c-43da-89a9-b84bf07e8913', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='d89bb7f5-9d1c-43da-89a9-b84bf07e8913'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d9d4ce4e-1ad5-43da-be38-b388e58be676', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='d9d4ce4e-1ad5-43da-be38-b388e58be676'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_da0ed261-6ad2-4951-9a8a-e4e925f811ad', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='da0ed261-6ad2-4951-9a8a-e4e925f811ad'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_da319701-6a94-49ac-8236-cbca06751728', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='da319701-6a94-49ac-8236-cbca06751728'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_da4b1f30-ee85-49ad-b859-69449ff3ad45', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='da4b1f30-ee85-49ad-b859-69449ff3ad45'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_de66a759-03c2-4db0-b2b1-2fecd81f91e1', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='de66a759-03c2-4db0-b2b1-2fecd81f91e1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_de94d4de-4d50-4a74-9ab0-4fc9bb0abd5f', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='de94d4de-4d50-4a74-9ab0-4fc9bb0abd5f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_dfbc50f4-cf44-4ca6-9950-10f21759b688', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='dfbc50f4-cf44-4ca6-9950-10f21759b688'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_dfc7583f-3a3a-4048-ae5a-e47a5f7b2902', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='dfc7583f-3a3a-4048-ae5a-e47a5f7b2902'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e0701684-e584-4612-bd37-42cdef0a5275', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='e0701684-e584-4612-bd37-42cdef0a5275'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e16e8836-0899-4723-b6b0-051f71efd9a0', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='e16e8836-0899-4723-b6b0-051f71efd9a0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e179218b-24b9-47a5-a1ce-9fd8901780c8', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='e179218b-24b9-47a5-a1ce-9fd8901780c8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e1a8c45a-ebfd-4919-bf04-3a7524837678', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e1a8c45a-ebfd-4919-bf04-3a7524837678'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e1e6b871-1eb7-4d10-998b-059f34ac8488', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='e1e6b871-1eb7-4d10-998b-059f34ac8488'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e3314347-c34e-40c1-aa24-38e03f569bb4', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='e3314347-c34e-40c1-aa24-38e03f569bb4'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e3867206-c2f2-4148-b722-6300c4177db8', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e3867206-c2f2-4148-b722-6300c4177db8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e39317ea-ad09-4cac-ac97-9cbfe46b5f69', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='e39317ea-ad09-4cac-ac97-9cbfe46b5f69'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e3db59b6-3b7b-4c95-b179-b4e447363313', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='e3db59b6-3b7b-4c95-b179-b4e447363313'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e3f8c028-c3bc-49b5-8983-3cf2f5340815', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e3f8c028-c3bc-49b5-8983-3cf2f5340815'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e424c715-c0fe-4aad-aa5e-f04c6c454ef4', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='e424c715-c0fe-4aad-aa5e-f04c6c454ef4'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e4a9dbf9-622c-4bde-abbe-9d838ecb794c', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='e4a9dbf9-622c-4bde-abbe-9d838ecb794c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e50f61d4-b6bd-45a5-b863-05a76fee8320', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='e50f61d4-b6bd-45a5-b863-05a76fee8320'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e51fbb44-bfd0-41dd-ac51-c9c0b92a0b66', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='e51fbb44-bfd0-41dd-ac51-c9c0b92a0b66'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e656083b-bdb0-4547-9478-d17790cac51b', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='e656083b-bdb0-4547-9478-d17790cac51b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e71ef654-396b-4ee5-8730-dd01b87335f3', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='e71ef654-396b-4ee5-8730-dd01b87335f3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e8875b8e-4638-4c6e-8afc-c0766999cc9f', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='e8875b8e-4638-4c6e-8afc-c0766999cc9f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e95c48de-706a-4026-a280-b5c79fb1c649', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='e95c48de-706a-4026-a280-b5c79fb1c649'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e9a39131-2949-40a6-b915-b34602cadf2f', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='e9a39131-2949-40a6-b915-b34602cadf2f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_eac1578c-880c-4945-b293-b64d50db3e86', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='eac1578c-880c-4945-b293-b64d50db3e86'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ead40546-c044-4818-aa30-85d1f91ad7ac', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='ead40546-c044-4818-aa30-85d1f91ad7ac'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_eaef0ad8-2a38-4417-b39b-252d5c17babb', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='eaef0ad8-2a38-4417-b39b-252d5c17babb'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ebd8cbdd-55ee-4a80-85fd-ef42168fdd89', query = "UPDATE clean_enumerations SET wid='428' WHERE instance_id='ebd8cbdd-55ee-4a80-85fd-ef42168fdd89'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ec195139-0413-4f3b-95ae-77c7db4f3330', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='ec195139-0413-4f3b-95ae-77c7db4f3330'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_eca3687d-ecab-4cfc-bcf0-8f5af30f91c7', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='eca3687d-ecab-4cfc-bcf0-8f5af30f91c7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ecc594e2-dbc9-46d2-a95e-dcbb8904a86a', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='ecc594e2-dbc9-46d2-a95e-dcbb8904a86a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ed00e124-9f32-4386-b925-c41c85f588e6', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='ed00e124-9f32-4386-b925-c41c85f588e6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ed098407-742b-4d41-8d0b-b6a96132c2cc', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='ed098407-742b-4d41-8d0b-b6a96132c2cc'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ee3a2c98-1703-4f3f-90a4-ffba3a189477', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='ee3a2c98-1703-4f3f-90a4-ffba3a189477'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ee802b4a-e9f9-4457-8f51-15a835847fae', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='ee802b4a-e9f9-4457-8f51-15a835847fae'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ef9a4880-a225-4ae6-8c72-36b6e7024998', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='ef9a4880-a225-4ae6-8c72-36b6e7024998'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_efa597b7-b593-4a12-bad2-882f9eb58310', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='efa597b7-b593-4a12-bad2-882f9eb58310'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_efbf39f5-46b0-42ce-80ae-9c49477cc147', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='efbf39f5-46b0-42ce-80ae-9c49477cc147'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f0cb9510-4160-4b4b-8fde-92b0a0539eeb', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='f0cb9510-4160-4b4b-8fde-92b0a0539eeb'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f0da5c81-b39a-49f2-9a77-6a1879af8447', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='f0da5c81-b39a-49f2-9a77-6a1879af8447'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f0e122e9-7269-403c-8c34-e8923502f24f', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='f0e122e9-7269-403c-8c34-e8923502f24f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f16b951c-b61e-4090-acdf-b66cee4a1451', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='f16b951c-b61e-4090-acdf-b66cee4a1451'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f1b2843d-a2d2-45ab-a998-1c8dd9332394', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='f1b2843d-a2d2-45ab-a998-1c8dd9332394'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f28dd34c-3997-4274-9058-f89910d4254b', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='f28dd34c-3997-4274-9058-f89910d4254b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f3036b1a-689e-4c85-9900-5dd5e0bda165', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='f3036b1a-689e-4c85-9900-5dd5e0bda165'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f3b3e969-dac7-4468-82cc-575baaab2888', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='f3b3e969-dac7-4468-82cc-575baaab2888'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f3d535fc-fe4c-4faa-a9ea-607b268f7ea8', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='f3d535fc-fe4c-4faa-a9ea-607b268f7ea8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f545f773-f426-4f26-bc91-26dfdf211a97', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='f545f773-f426-4f26-bc91-26dfdf211a97'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f6b221a3-ba06-4d42-ad9c-250fa6c7cbe8', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='f6b221a3-ba06-4d42-ad9c-250fa6c7cbe8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f72f8553-77f2-4f62-9c56-a9b48c854a3a', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='f72f8553-77f2-4f62-9c56-a9b48c854a3a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f77f13c2-8bde-4789-b10f-9b792eba76b7', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='f77f13c2-8bde-4789-b10f-9b792eba76b7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f78f8dbe-d850-4b6e-ae45-c2298b056134', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='f78f8dbe-d850-4b6e-ae45-c2298b056134'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f9039d4c-4ec7-4b7c-b103-b9331ff35151', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='f9039d4c-4ec7-4b7c-b103-b9331ff35151'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fa94e9e9-caf9-4bbf-b147-6c0c3c797c93', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='fa94e9e9-caf9-4bbf-b147-6c0c3c797c93'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fac91b1f-9007-4301-99c9-bdf2c7930533', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='fac91b1f-9007-4301-99c9-bdf2c7930533'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_faf1ffd0-cb94-4f4a-a066-4b745e95f90a', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='faf1ffd0-cb94-4f4a-a066-4b745e95f90a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fb3c301e-a9ec-4ab5-8e04-a55be60e4a37', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='fb3c301e-a9ec-4ab5-8e04-a55be60e4a37'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fba706b6-9d56-4c2b-89f8-efa4070ab5c3', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='fba706b6-9d56-4c2b-89f8-efa4070ab5c3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fc67fde4-e844-4832-816e-1b5cd0bdd400', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='fc67fde4-e844-4832-816e-1b5cd0bdd400'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fd694b29-3a65-4fc6-9110-bff00098940f', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='fd694b29-3a65-4fc6-9110-bff00098940f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fd797b50-0ee0-4d30-b4e9-4ebe45e554be', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='fd797b50-0ee0-4d30-b4e9-4ebe45e554be'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fdce285f-325f-40eb-94dd-8fd9f3d795aa', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='fdce285f-325f-40eb-94dd-8fd9f3d795aa'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ff7b4ff3-e34e-47d6-bff4-11417d5b3642', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='ff7b4ff3-e34e-47d6-bff4-11417d5b3642'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ffa1bd93-5c82-417d-9afe-8e4608da8052', query = "UPDATE clean_enumerations SET wid='338' WHERE instance_id='ffa1bd93-5c82-417d-9afe-8e4608da8052'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_4022bf4c-c760-479b-9553-ae98d3025824', query = "UPDATE clean_enumerations SET wid='395' WHERE instance_id='4022bf4c-c760-479b-9553-ae98d3025824'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_49c1ce36-8372-4878-9fbb-63136cdb4dae', query = "UPDATE clean_enumerations SET wid='370' WHERE instance_id='49c1ce36-8372-4878-9fbb-63136cdb4dae'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_0117bfd9-646b-471b-9280-05518dd221cf', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='0117bfd9-646b-471b-9280-05518dd221cf'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_047f3924-e2f9-47d1-8a5c-7103e15c0cb6', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='047f3924-e2f9-47d1-8a5c-7103e15c0cb6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_051cc4d2-f470-4f6d-96a0-2a5228cf2bf3', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='051cc4d2-f470-4f6d-96a0-2a5228cf2bf3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_0667e0cc-33cf-40bd-977c-43ea956e17a5', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='0667e0cc-33cf-40bd-977c-43ea956e17a5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_07d58aee-1bd8-4d89-90e1-9ef726128f6f', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='07d58aee-1bd8-4d89-90e1-9ef726128f6f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_08ff643e-7222-4520-b30d-61d53cde80da', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='08ff643e-7222-4520-b30d-61d53cde80da'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_0a8a164c-7f28-47e6-b24e-884a9ec1166a', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='0a8a164c-7f28-47e6-b24e-884a9ec1166a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_0b8d02a9-edbc-4b7b-a07f-df57826bc5b2', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='0b8d02a9-edbc-4b7b-a07f-df57826bc5b2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_0c96c3cb-c13d-4c31-83df-0b4b36802d70', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='0c96c3cb-c13d-4c31-83df-0b4b36802d70'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_129c8cb7-1c40-429b-8273-dc9344806ba0', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='129c8cb7-1c40-429b-8273-dc9344806ba0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_13ba766a-4f82-4076-b8cd-c2a38923058b', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='13ba766a-4f82-4076-b8cd-c2a38923058b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_13d42b57-d0a4-4ccd-adf0-54874728b5a2', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='13d42b57-d0a4-4ccd-adf0-54874728b5a2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_147268fe-1266-41fd-a822-9560f28d3c1e', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='147268fe-1266-41fd-a822-9560f28d3c1e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_14774355-11aa-4387-9022-3d4887675af0', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='14774355-11aa-4387-9022-3d4887675af0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_15a5f007-9fc8-4419-8114-85c9a5c2c6b1', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='15a5f007-9fc8-4419-8114-85c9a5c2c6b1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_16a59757-3535-4cb0-80e2-dd3afa620ce8', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='16a59757-3535-4cb0-80e2-dd3afa620ce8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_1a086387-f7d7-4fe1-9d98-2db196d8a13e', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='1a086387-f7d7-4fe1-9d98-2db196d8a13e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_1bcb486e-be09-413e-84b4-2c2d8a3e0edd', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='1bcb486e-be09-413e-84b4-2c2d8a3e0edd'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_26739a06-9746-46aa-92ac-6d6e5477bd56', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='26739a06-9746-46aa-92ac-6d6e5477bd56'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_27491d38-5cbc-4c02-be5c-ee95e2ec348a', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='27491d38-5cbc-4c02-be5c-ee95e2ec348a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_2a71ec7e-8fa1-410d-be6f-cc33a4c60d79', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='2a71ec7e-8fa1-410d-be6f-cc33a4c60d79'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_2fe690a0-1858-4b49-adcd-3902b021fbc9', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='2fe690a0-1858-4b49-adcd-3902b021fbc9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_308dd1b2-0a10-4c39-84db-392501e47fef', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='308dd1b2-0a10-4c39-84db-392501e47fef'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_313df92d-ed71-4a30-87eb-155d3f440573', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='313df92d-ed71-4a30-87eb-155d3f440573'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_3155fac9-39da-4fa1-a78c-23b1f6475c8b', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='3155fac9-39da-4fa1-a78c-23b1f6475c8b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_31f73c7b-abaa-4e6e-a6dc-623943658c4c', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='31f73c7b-abaa-4e6e-a6dc-623943658c4c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_322a177c-8edb-4756-a96d-e54c9cdd3209', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='322a177c-8edb-4756-a96d-e54c9cdd3209'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_3445aafb-4d88-49e6-a84d-19b35bb29fb6', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='3445aafb-4d88-49e6-a84d-19b35bb29fb6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_3510008b-7477-4f7f-9f51-11ae4ba5b1dd', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='3510008b-7477-4f7f-9f51-11ae4ba5b1dd'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_35a54f3c-2abb-42c7-9e82-a52e85923adf', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='35a54f3c-2abb-42c7-9e82-a52e85923adf'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_36f55cea-69b6-4b0e-bc51-92a816ee7ebe', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='36f55cea-69b6-4b0e-bc51-92a816ee7ebe'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_3bc7e8a1-8dd4-4cd8-aa95-da8fea85a4c7', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='3bc7e8a1-8dd4-4cd8-aa95-da8fea85a4c7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_3e51b65e-358e-4760-b80d-88e92422d651', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='3e51b65e-358e-4760-b80d-88e92422d651'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_3e5bb9b5-3135-4f65-a7ef-5ea60546ee52', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='3e5bb9b5-3135-4f65-a7ef-5ea60546ee52'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_3f2447a7-5110-4287-92ca-2456efd0d31c', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='3f2447a7-5110-4287-92ca-2456efd0d31c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_3f3cc891-7e9c-4980-8da4-5f3637d6e194', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='3f3cc891-7e9c-4980-8da4-5f3637d6e194'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_40639067-ee74-41bf-ab72-476bcfdd54ff', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='40639067-ee74-41bf-ab72-476bcfdd54ff'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_410d2086-7f72-48c1-b73a-61b1e8aa7823', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='410d2086-7f72-48c1-b73a-61b1e8aa7823'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_42fe3545-019e-4802-bac4-871daa2efe46', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='42fe3545-019e-4802-bac4-871daa2efe46'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_44ae5897-6a24-4cb2-9000-62fa7dd5283c', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='44ae5897-6a24-4cb2-9000-62fa7dd5283c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_476b3c7e-83be-4d40-b024-361407c98840', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='476b3c7e-83be-4d40-b024-361407c98840'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_49da60c0-ebf5-44e6-9d07-9a749f3a9bf2', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='49da60c0-ebf5-44e6-9d07-9a749f3a9bf2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_4af63db0-840b-4248-af82-9ddfab124992', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='4af63db0-840b-4248-af82-9ddfab124992'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_4e388779-6abb-4361-83f1-a4841c74ee26', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='4e388779-6abb-4361-83f1-a4841c74ee26'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_50a38c61-7774-4426-ba0f-ebb1765ac621', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='50a38c61-7774-4426-ba0f-ebb1765ac621'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_551b27b5-9149-4099-9b6d-23980b70bf9f', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='551b27b5-9149-4099-9b6d-23980b70bf9f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_58b8167c-5148-4400-91f4-b0b46bfae111', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='58b8167c-5148-4400-91f4-b0b46bfae111'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_59e94d6f-077f-43aa-abf7-c8fba0716829', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='59e94d6f-077f-43aa-abf7-c8fba0716829'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5a3b8203-1cac-437d-9bc6-f3f1fac8c905', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='5a3b8203-1cac-437d-9bc6-f3f1fac8c905'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5a90f754-e416-45f6-9baf-9083f58cd569', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='5a90f754-e416-45f6-9baf-9083f58cd569'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5b602de1-ef2a-4d35-bf3f-6ac0214de48e', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='5b602de1-ef2a-4d35-bf3f-6ac0214de48e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5b96d727-b6fe-45b3-b72e-20b6f9636780', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='5b96d727-b6fe-45b3-b72e-20b6f9636780'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_5db0a910-788e-455f-84df-e1faaef0383d', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='5db0a910-788e-455f-84df-e1faaef0383d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_600a03c1-6ba3-481a-8bf1-aefd6f21c624', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='600a03c1-6ba3-481a-8bf1-aefd6f21c624'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_611d1c3f-6614-43fb-b8e1-ec5aaaccdcc5', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='611d1c3f-6614-43fb-b8e1-ec5aaaccdcc5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_614a8b10-3214-45c4-a4e6-92aae498087c', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='614a8b10-3214-45c4-a4e6-92aae498087c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_61e4f1e7-2d1b-4f17-aafe-c03c8986e885', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='61e4f1e7-2d1b-4f17-aafe-c03c8986e885'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_622deef1-66b9-4ca9-977f-ce3f80e03543', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='622deef1-66b9-4ca9-977f-ce3f80e03543'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_64e7e8ee-3fd0-46e7-800f-469d1ab2f4af', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='64e7e8ee-3fd0-46e7-800f-469d1ab2f4af'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_66b55596-8181-4f51-b0cb-cb8bfedf79a5', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='66b55596-8181-4f51-b0cb-cb8bfedf79a5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_66d2b7d9-cc2c-443b-8866-33b6f7e14838', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='66d2b7d9-cc2c-443b-8866-33b6f7e14838'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_67c9b055-9b8a-405a-8b88-1a172f4fe42a', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='67c9b055-9b8a-405a-8b88-1a172f4fe42a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_69061f5f-9690-4b4e-abcc-4bfcd6dccfff', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='69061f5f-9690-4b4e-abcc-4bfcd6dccfff'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_69ad872c-14bb-4cb0-ad7d-12e4f2992949', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='69ad872c-14bb-4cb0-ad7d-12e4f2992949'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6c851a89-215b-4736-8c90-ccfacda92841', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='6c851a89-215b-4736-8c90-ccfacda92841'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6d36709d-d143-4fa2-9c57-078f869b08da', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='6d36709d-d143-4fa2-9c57-078f869b08da'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6f3c7aae-52bd-4a17-95ef-b86b3286a16b', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='6f3c7aae-52bd-4a17-95ef-b86b3286a16b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_6fbe72ec-2cc4-4e18-8d4a-f4076d31380f', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='6fbe72ec-2cc4-4e18-8d4a-f4076d31380f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7184fe1a-e9ec-40f9-81c0-fcc90983e03e', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='7184fe1a-e9ec-40f9-81c0-fcc90983e03e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_72401d98-9b45-4354-bd46-93491a2a4ce7', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='72401d98-9b45-4354-bd46-93491a2a4ce7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_77529b3d-783c-41eb-922e-eaf69499c0c0', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='77529b3d-783c-41eb-922e-eaf69499c0c0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_776561e9-5098-4e0f-ac57-0a7bd1339444', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='776561e9-5098-4e0f-ac57-0a7bd1339444'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_77941132-8a1a-4896-b998-780ff6ab5148', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='77941132-8a1a-4896-b998-780ff6ab5148'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_77b22a77-3235-485f-9b00-5e3846d3259d', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='77b22a77-3235-485f-9b00-5e3846d3259d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7a7270d1-93c4-4429-8241-9f24fc62d9d9', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='7a7270d1-93c4-4429-8241-9f24fc62d9d9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7d33be72-1884-4085-9452-5c0fae2945c9', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='7d33be72-1884-4085-9452-5c0fae2945c9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7e23e580-3428-4ecb-a0e7-7efa1ead5d59', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='7e23e580-3428-4ecb-a0e7-7efa1ead5d59'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_7f2a1195-edfa-4dbe-abaa-10f4667af821', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='7f2a1195-edfa-4dbe-abaa-10f4667af821'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_82ad6c3e-05a7-4238-b735-5e658e155db4', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='82ad6c3e-05a7-4238-b735-5e658e155db4'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8390dcde-fa5a-4359-af8e-b2d40f83d56c', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='8390dcde-fa5a-4359-af8e-b2d40f83d56c'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_876df0a6-9cb6-4239-bf35-6af3d3fe1cab', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='876df0a6-9cb6-4239-bf35-6af3d3fe1cab'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_88f20085-fc81-4d67-987c-f75ac9e7fbd6', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='88f20085-fc81-4d67-987c-f75ac9e7fbd6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8a09fa1a-6940-4f44-9b4e-e8689fa70596', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='8a09fa1a-6940-4f44-9b4e-e8689fa70596'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8c9fa53e-eb81-49a7-bc65-a000d0e4f4b3', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='8c9fa53e-eb81-49a7-bc65-a000d0e4f4b3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8d0c6387-8c23-4e3a-af1b-b32dd78cd98a', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='8d0c6387-8c23-4e3a-af1b-b32dd78cd98a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8db070f5-341c-484f-9dd6-dc96071ff8d4', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='8db070f5-341c-484f-9dd6-dc96071ff8d4'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8ed9bcab-eeff-4fab-aa04-dd6be622f906', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='8ed9bcab-eeff-4fab-aa04-dd6be622f906'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8ef3da38-5c11-471d-9faf-bd5f09e2a2bc', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='8ef3da38-5c11-471d-9faf-bd5f09e2a2bc'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8f8eadfe-f8cc-4535-a218-a9f7b4407ae7', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='8f8eadfe-f8cc-4535-a218-a9f7b4407ae7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_8ff8949f-8fd8-4575-9070-c2e9667b24ca', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='8ff8949f-8fd8-4575-9070-c2e9667b24ca'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_91a261d6-c9a8-4d15-ac53-2eb4bf74c7e8', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='91a261d6-c9a8-4d15-ac53-2eb4bf74c7e8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_936b61fb-01b5-4b44-8ae5-608e50829941', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='936b61fb-01b5-4b44-8ae5-608e50829941'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_956da7e3-9dff-4592-a00f-aa0df4c405ea', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='956da7e3-9dff-4592-a00f-aa0df4c405ea'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_97002f56-4622-4fbd-8548-08de3edc3f73', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='97002f56-4622-4fbd-8548-08de3edc3f73'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_970a203c-ce37-4223-b1c9-13165b2049c3', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='970a203c-ce37-4223-b1c9-13165b2049c3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9941fdd0-c3f4-41e7-a293-08522510ec4f', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='9941fdd0-c3f4-41e7-a293-08522510ec4f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_99514be2-8b4c-43ec-91d7-d4a4bf3e9150', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='99514be2-8b4c-43ec-91d7-d4a4bf3e9150'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_99fa1128-e034-46bb-8e3e-daabdeadbc6e', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='99fa1128-e034-46bb-8e3e-daabdeadbc6e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9ab16c24-7dc4-4b24-ae47-6e23d9ab9abe', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='9ab16c24-7dc4-4b24-ae47-6e23d9ab9abe'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9ad51aec-4f77-4d5b-b207-dda141e4273f', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='9ad51aec-4f77-4d5b-b207-dda141e4273f'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9d310f1b-bfc1-4baa-ae38-6f545750912b', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='9d310f1b-bfc1-4baa-ae38-6f545750912b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_9f27b9de-3f98-4fb5-a5df-7bc6d5823f5a', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='9f27b9de-3f98-4fb5-a5df-7bc6d5823f5a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a0398367-8ec2-4a40-a423-e0254293e17e', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='a0398367-8ec2-4a40-a423-e0254293e17e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a13cee83-36ce-45bc-9d27-9e2475133db5', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='a13cee83-36ce-45bc-9d27-9e2475133db5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a491482b-1752-4514-99b6-467f73856f32', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='a491482b-1752-4514-99b6-467f73856f32'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a4e29d3b-43ed-461d-af48-e3e91fb69230', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='a4e29d3b-43ed-461d-af48-e3e91fb69230'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a6532dd6-f2a0-4835-b344-ee3b4f015928', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='a6532dd6-f2a0-4835-b344-ee3b4f015928'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_a8d2bc76-64d7-4c17-a1c8-edb8031c4937', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='a8d2bc76-64d7-4c17-a1c8-edb8031c4937'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_aacba9cd-2325-43c6-ba52-641d2074bda8', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='aacba9cd-2325-43c6-ba52-641d2074bda8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_abdbe291-2394-48bb-8d75-84a5782bd465', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='abdbe291-2394-48bb-8d75-84a5782bd465'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ac1e2d87-ac52-4a3e-bf38-13af7f274d99', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='ac1e2d87-ac52-4a3e-bf38-13af7f274d99'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_add1c4df-e017-4dfe-b81c-964ea4983d32', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='add1c4df-e017-4dfe-b81c-964ea4983d32'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_afb1eea7-dd54-4329-9fb4-216ffb5d06d6', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='afb1eea7-dd54-4329-9fb4-216ffb5d06d6'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_afe7a350-665c-485d-ac44-d9f4a543acc8', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='afe7a350-665c-485d-ac44-d9f4a543acc8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b256325a-eb2f-4938-b381-4d423e7a3ff4', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='b256325a-eb2f-4938-b381-4d423e7a3ff4'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b2d65ad6-f972-4def-ad38-cddcc379d1d9', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='b2d65ad6-f972-4def-ad38-cddcc379d1d9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b2fae474-f19c-41d3-8493-a997bc73f0a1', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='b2fae474-f19c-41d3-8493-a997bc73f0a1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b3bf9ff5-7b33-4712-9d26-58992f3072ed', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='b3bf9ff5-7b33-4712-9d26-58992f3072ed'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b4d213b9-0f73-458c-9f17-5c419912344d', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='b4d213b9-0f73-458c-9f17-5c419912344d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_b833718b-7472-4b53-a83e-a86996c6f747', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='b833718b-7472-4b53-a83e-a86996c6f747'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bab337a4-9b5b-4675-a484-4d564742f8ce', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='bab337a4-9b5b-4675-a484-4d564742f8ce'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bc17f4e4-5840-4daf-aeb9-c1655616c782', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='bc17f4e4-5840-4daf-aeb9-c1655616c782'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bd0ffc6e-a0c9-4443-932c-008198e02e96', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='bd0ffc6e-a0c9-4443-932c-008198e02e96'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bdb6a241-6ca8-49a1-bf30-7b1ec6ab4d1a', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='bdb6a241-6ca8-49a1-bf30-7b1ec6ab4d1a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_bf7dd607-48de-4254-ab4d-032926c3966e', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='bf7dd607-48de-4254-ab4d-032926c3966e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c02136e4-44f8-4dde-9186-13b27d00a0d2', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='c02136e4-44f8-4dde-9186-13b27d00a0d2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c0ae8cf4-b1e9-4041-81aa-8455aa4a5e88', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='c0ae8cf4-b1e9-4041-81aa-8455aa4a5e88'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c143beea-152d-4d4d-a8df-bac8fe028717', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='c143beea-152d-4d4d-a8df-bac8fe028717'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c15b41e4-60aa-4a21-96d1-b69f1b5f0821', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='c15b41e4-60aa-4a21-96d1-b69f1b5f0821'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c2a1a67d-c3c4-427b-9184-6afd75b7a314', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='c2a1a67d-c3c4-427b-9184-6afd75b7a314'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c34bd657-31b1-413a-b31d-95d93f30357e', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='c34bd657-31b1-413a-b31d-95d93f30357e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c35f88f5-7fff-4430-9ea1-d6989a70bf58', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='c35f88f5-7fff-4430-9ea1-d6989a70bf58'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c3ef1c24-57e6-4fc0-99f7-6d7f975a7ec2', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='c3ef1c24-57e6-4fc0-99f7-6d7f975a7ec2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_c4c941f4-d074-4c53-afae-d56edcd56be9', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='c4c941f4-d074-4c53-afae-d56edcd56be9'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cb7a4490-64cd-4d18-b7d1-b7425ed48dbe', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='cb7a4490-64cd-4d18-b7d1-b7425ed48dbe'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cb96f20d-0032-4d86-9919-6811dcc54a53', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='cb96f20d-0032-4d86-9919-6811dcc54a53'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_cc5454a2-6099-4af4-ba84-a550cadd358a', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='cc5454a2-6099-4af4-ba84-a550cadd358a'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d59d3eaa-65da-4caa-a155-43d0313fe4e2', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='d59d3eaa-65da-4caa-a155-43d0313fe4e2'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d5a2d8e7-c97b-4222-9c8a-d0f9ea312fb8', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='d5a2d8e7-c97b-4222-9c8a-d0f9ea312fb8'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d77a6be7-2600-43ca-9fa3-53c2b9df8058', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='d77a6be7-2600-43ca-9fa3-53c2b9df8058'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_d9256e3e-c3d3-41d6-85f9-da939d718879', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='d9256e3e-c3d3-41d6-85f9-da939d718879'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_dc3602b9-a929-42c4-acdd-614a893907c7', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='dc3602b9-a929-42c4-acdd-614a893907c7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_dc398b5f-d1bc-4b5d-9948-093bfd0a12da', query = "UPDATE clean_enumerations SET wid='329' WHERE instance_id='dc398b5f-d1bc-4b5d-9948-093bfd0a12da'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_dc5f24d6-5afb-4695-b988-5dbb2faa3db1', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='dc5f24d6-5afb-4695-b988-5dbb2faa3db1'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_dd09b512-6c52-4b54-b153-4d8d91020dde', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='dd09b512-6c52-4b54-b153-4d8d91020dde'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_def631e4-c008-434f-9054-9e231ac9a460', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='def631e4-c008-434f-9054-9e231ac9a460'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e058b681-eeea-4b1c-83ff-6e00b527c778', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='e058b681-eeea-4b1c-83ff-6e00b527c778'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e17528a7-04b7-4483-b887-af73f5f87fbe', query = "UPDATE clean_enumerations SET wid='427' WHERE instance_id='e17528a7-04b7-4483-b887-af73f5f87fbe'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e19fed81-06fa-4b7f-b54a-ce5b9b0cfd30', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='e19fed81-06fa-4b7f-b54a-ce5b9b0cfd30'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e4534c89-1d37-47b7-85e6-f56b461acc2e', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='e4534c89-1d37-47b7-85e6-f56b461acc2e'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e510da8b-5b8c-4c40-ac04-9df1bbbf26c7', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='e510da8b-5b8c-4c40-ac04-9df1bbbf26c7'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e7bf8e5d-5a15-4d19-8c2c-cdc32b5393ce', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='e7bf8e5d-5a15-4d19-8c2c-cdc32b5393ce'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_e83622b2-2c69-469a-9e5a-d519af1c7269', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='e83622b2-2c69-469a-9e5a-d519af1c7269'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ebacfa1d-f62b-4eab-a2d3-c1769b8bd5e5', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='ebacfa1d-f62b-4eab-a2d3-c1769b8bd5e5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_eefd9412-0c3f-4a3d-be1b-8cb3b7a732b0', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='eefd9412-0c3f-4a3d-be1b-8cb3b7a732b0'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f4fb192e-c4cb-408e-938d-5dca05087e4b', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='f4fb192e-c4cb-408e-938d-5dca05087e4b'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f4fe11b0-b74d-4fb0-804a-5e1d677ee7c3', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='f4fe11b0-b74d-4fb0-804a-5e1d677ee7c3'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_f517041e-3f8c-41bd-ad3a-e3657271eb30', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='f517041e-3f8c-41bd-ad3a-e3657271eb30'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fc7c440c-db44-4670-a06f-af8458fb047d', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='fc7c440c-db44-4670-a06f-af8458fb047d'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fca68a8a-60bc-43f7-8683-373432e82f99', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='fca68a8a-60bc-43f7-8683-373432e82f99'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_fd6ddcd5-c8af-4651-940e-7355efc8c5a5', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='fd6ddcd5-c8af-4651-940e-7355efc8c5a5'", who = 'Joe Brew')

implement(id = 'strange_wid_enumerations_ff0011c8-e234-4706-bc68-d4bf1fcd1fae', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='ff0011c8-e234-4706-bc68-d4bf1fcd1fae'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_037aa18e-1d51-4f4a-aaee-8c1971bc9e46', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='037aa18e-1d51-4f4a-aaee-8c1971bc9e46'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_1bf6e21c-babc-4e2a-9817-8b31dbeeae58', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='1bf6e21c-babc-4e2a-9817-8b31dbeeae58'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_342aad87-ec45-4a11-bd99-cb093eca9a34', query = "UPDATE clean_enumerations SET wid='329' WHERE instance_id='342aad87-ec45-4a11-bd99-cb093eca9a34'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_3c3d5470-8e1d-4987-90b3-60d7db9ca4fb', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='3c3d5470-8e1d-4987-90b3-60d7db9ca4fb'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_3ffd4043-0852-47aa-ac1a-34e19ea41236', query = "UPDATE clean_enumerations SET wid='429' WHERE instance_id='3ffd4043-0852-47aa-ac1a-34e19ea41236'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_425b1fc1-c7f2-43ac-82c6-67ac878a9138', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='425b1fc1-c7f2-43ac-82c6-67ac878a9138'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_456c1cbb-f769-4616-a424-27c711cb42f7', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='456c1cbb-f769-4616-a424-27c711cb42f7'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_6389d2ad-db0a-46bc-9dae-13f3f873b365', query = "UPDATE clean_enumerations SET wid='423' WHERE instance_id='6389d2ad-db0a-46bc-9dae-13f3f873b365'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_694d12e7-cc1a-46dd-931a-38b71e320237', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='694d12e7-cc1a-46dd-931a-38b71e320237'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_6a809dc2-138e-4ae2-b21d-6f85a7020e89', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='6a809dc2-138e-4ae2-b21d-6f85a7020e89'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_7309f2d5-c1be-441d-b584-614de18e8cd4', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='7309f2d5-c1be-441d-b584-614de18e8cd4'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_765d1380-36c6-47a5-af9e-905def0872f9', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='765d1380-36c6-47a5-af9e-905def0872f9'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_80d0a986-a948-469c-b3af-1ef21409919e', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='80d0a986-a948-469c-b3af-1ef21409919e'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_bda17930-e2be-4351-84e8-25cbab9aaa9b', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='bda17930-e2be-4351-84e8-25cbab9aaa9b'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_d095f0c6-a77d-4ece-92d7-c542b64ba1ee', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id='d095f0c6-a77d-4ece-92d7-c542b64ba1ee'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_d21c4261-5fbf-41da-b446-bf4579b778f7', query = "UPDATE clean_enumerations SET wid='425' WHERE instance_id='d21c4261-5fbf-41da-b446-bf4579b778f7'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_ead5c0af-dcdf-4192-a43a-1b24e96baf92', query = "UPDATE clean_enumerations SET wid='422' WHERE instance_id='ead5c0af-dcdf-4192-a43a-1b24e96baf92'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_ebdfc342-8745-4115-bfc5-cced7210fb52', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='ebdfc342-8745-4115-bfc5-cced7210fb52'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_efb030c6-9371-4420-bfb4-6d5e09d158fc', query = "UPDATE clean_enumerations SET wid='426' WHERE instance_id='efb030c6-9371-4420-bfb4-6d5e09d158fc'", who = 'Joe Brew')

implement(id = 'missing_wid_enumerations_fd419ea7-056c-4a98-8dfe-ae148467b37b', query = "UPDATE clean_enumerations SET wid='424' WHERE instance_id='fd419ea7-056c-4a98-8dfe-ae148467b37b'", who = 'Joe Brew')

iid = "'addcd14f-a887-42b9-9c4d-5f475bfecd22'"
implement(id = 'repeat_hh_id_addcd14f-a887-42b9-9c4d-5f475bfecd22,e5651bb0-ed12-451a-ad51-dee635862a7f', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'5a80ba29-077c-4c13-bfda-9cd3e1415a4a'"
implement(id = 'repeat_hh_id_5a80ba29-077c-4c13-bfda-9cd3e1415a4a,9dabcbd6-11c8-4345-9b23-3d4ee976465f', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'4994bf5c-88fd-47ec-b3cb-4ee0e51ac7a4'"
implement(id = 'repeat_hh_id_4994bf5c-88fd-47ec-b3cb-4ee0e51ac7a4,ee265069-4077-4d54-9d6d-6650faddadfb', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

# Picked wrong person for household head
implement(id = 'hh_head_too_young_old_7a5d2620-32cd-4dca-b193-df563a770f69', query = "UPDATE clean_minicensus_main SET hh_head_id='2' WHERE instance_id='7a5d2620-32cd-4dca-b193-df563a770f69'; UPDATE clean_minicensus_main SET hh_head_dob='1999-12-24' WHERE instance_id='7a5d2620-32cd-4dca-b193-df563a770f69'; UPDATE clean_minicensus_main SET hh_head_gender='female' WHERE instance_id='7a5d2620-32cd-4dca-b193-df563a770f69';")





# TZA
implement(id = 'missing_wid_3cb21b8a-65b1-487f-93ad-5e7c3bf317a1', query = "UPDATE clean_minicensus_main SET wid='3' WHERE instance_id='3cb21b8a-65b1-487f-93ad-5e7c3bf317a1'")
implement(id = 'strange_wid_5f466226-1d75-40a9-97fc-5e8cd84448c9', query = "UPDATE clean_minicensus_main SET wid='37' WHERE instance_id='5f466226-1d75-40a9-97fc-5e8cd84448c9'")
implement(id = 'missing_wid_23632449-cb8d-4ea2-a705-4d9f145b352c', query = "UPDATE clean_minicensus_main SET wid='80' WHERE instance_id='23632449-cb8d-4ea2-a705-4d9f145b352c'")
implement(id = 'missing_wid_ee4aca39-2370-49c2-a01e-a295638038e9', query = "UPDATE clean_minicensus_main SET wid='14' WHERE instance_id='ee4aca39-2370-49c2-a01e-a295638038e9'")

iid = "'7ac74d0a-7eb9-4651-a2a6-ee7d8edd7059'"
implement(id = 'repeat_hh_id_564fe4e1-1978-4bc5-84b4-d80adb7a9bde,7ac74d0a-7eb9-4651-a2a6-ee7d8edd7059', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'36527774-d88c-4b97-8722-b881171ff77c'"
implement(id = 'repeat_hh_id_36527774-d88c-4b97-8722-b881171ff77c,3be77a06-5646-49fe-9037-f0ff3bc40543', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

implement(id = 'missing_wid_6de89fa4-8933-4486-931d-7fdb951c902b', query = "UPDATE clean_minicensus_main SET wid='80' WHERE instance_id='6de89fa4-8933-4486-931d-7fdb951c902b'")
implement(id = 'missing_wid_a71799cc-e54c-473b-a279-1570c5a42b92', query = "UPDATE clean_minicensus_main SET wid='74' WHERE instance_id='a71799cc-e54c-473b-a279-1570c5a42b92'")


iid = "'046297df-1517-43af-b670-30255b77807d'"
implement(id = 'repeat_hh_id_046297df-1517-43af-b670-30255b77807d,4595f8dc-235c-4f69-beac-f3c06b9ad9b2', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'e607306d-f050-4fdf-94f2-eb5ff6d4db0d'"
implement(id = 'repeat_hh_id_04bc6d7c-578a-47e5-8f72-28a483c2fb3f,e607306d-f050-4fdf-94f2-eb5ff6d4db0d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'84914d5a-f64c-4a47-9110-aca348d85fe5'"
implement(id = 'repeat_hh_id_18439bc9-963b-427f-b906-a21814454e27,84914d5a-f64c-4a47-9110-aca348d85fe5', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'c2b36a0c-52c6-4119-8a49-d3957d67e941'"
implement(id = 'repeat_hh_id_a68ac273-abe7-41a9-bc20-249d28d33be5,c2b36a0c-52c6-4119-8a49-d3957d67e941', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'322322bc-a12b-4794-9981-0d473aed210d'"
implement(id = 'repeat_hh_id_28e64506-5bbe-4717-8d2d-407498284d3b,322322bc-a12b-4794-9981-0d473aed210d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'3fca1b08-a60a-432a-ad7d-ebaafff4fe33'"
implement(id = 'repeat_hh_id_8513c270-934d-46a9-8b9d-c80fe7c2e974,3fca1b08-a60a-432a-ad7d-ebaafff4fe33', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'356ff91b-668e-4a82-849a-fb188f3fdeee'"
implement(id = 'repeat_hh_id_a47d41c9-6f77-4d41-a1fe-40d5cb327491,356ff91b-668e-4a82-849a-fb188f3fdeee', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'7844442f-2813-421f-a5d2-deff680a161c'"
implement(id = 'repeat_hh_id_94284e9b-ad61-496f-885e-b1741189d4a3,7844442f-2813-421f-a5d2-deff680a161c', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'cd0e2222-3496-45f7-a603-85f9447ac233'"
implement(id = 'repeat_hh_id_04892ea2-e389-4f1c-bf91-54f56a15ae46,cd0e2222-3496-45f7-a603-85f9447ac233', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

implement(id = 'missing_wid_2d72c6ba-dc82-45e1-a8d8-144781c7b72e', query = "UPDATE clean_minicensus_main SET wid='74' WHERE instance_id='2d72c6ba-dc82-45e1-a8d8-144781c7b72e'")

iid = "'d00884cc-65ed-4784-85a4-dea6ca3f46eb'"
implement(id = 'repeat_hh_id_4c66d0d7-9571-4449-bc08-bd79f45fa1da,d00884cc-65ed-4784-85a4-dea6ca3f46eb', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'f2939b12-099e-4378-ab6b-a095e217bcf9'"
implement(id = 'repeat_hh_id_b804d947-5524-4a18-af16-83975587509d,f2939b12-099e-4378-ab6b-a095e217bcf9', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'f15d4b99-5056-434d-9ed3-e1b4df61a19c'"
implement(id = 'repeat_hh_id_3bff571f-3ffb-415d-be55-e1986a816847,f15d4b99-5056-434d-9ed3-e1b4df61a19c', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'7d2ff42f-aa74-4c5f-896c-6f86b60dc938'"
implement(id = 'repeat_hh_id_125e6809-84f3-433d-888e-e99477395ed3,7d2ff42f-aa74-4c5f-896c-6f86b60dc938', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'cce8909b-6ef2-4394-9372-1bd4899e08bf'"
implement(id = 'repeat_hh_id_cce8909b-6ef2-4394-9372-1bd4899e08bf,79f53b02-9a1c-464f-900b-1cfbdbb911dc', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'9bb234f3-5c83-4173-a147-7b1f50392ee0'"
implement(id = 'repeat_hh_id_69ae2b9f-0bdd-4604-b62d-3856d8fded5d,9bb234f3-5c83-4173-a147-7b1f50392ee0', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'643a1ae6-7219-4db5-9231-e65ed63b6ae5'"
implement(id = 'repeat_hh_id_14de102e-2672-4823-ab41-5f707afa4cc3,643a1ae6-7219-4db5-9231-e65ed63b6ae5', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'2187ebbc-a289-4afd-8399-2694e34cf73d'"
implement(id = 'repeat_hh_id_10b7d4d9-5c99-49fb-aa80-7a578bac2619,2187ebbc-a289-4afd-8399-2694e34cf73d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'43814b5c-3666-4153-acfc-91b2a5d915fe'"
implement(id = 'repeat_hh_id_43814b5c-3666-4153-acfc-91b2a5d915fe,8d0077a0-3678-4d4e-95dc-01829ddb0f3d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'a6195ece-1f15-4a56-9335-90c1af814329'"
implement(id = 'repeat_hh_id_bc7614f4-9d1e-46dd-bcac-ae8603d2c1d0,a6195ece-1f15-4a56-9335-90c1af814329', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'34af8873-c4f7-47aa-aa8d-84635746d010'"
implement(id = 'repeat_hh_id_34af8873-c4f7-47aa-aa8d-84635746d010,f1201d75-a6e3-4766-80aa-43f89475ee08', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'9a691d71-1620-41da-a8d2-c66fd386c696'"
implement(id = 'repeat_hh_id_9a691d71-1620-41da-a8d2-c66fd386c696,a4ecd543-0c52-4ea3-bb08-6ea43d12270d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

iid = "'d1f79a1e-2844-4c98-ac20-9f3ca0bd8df0'"
implement(id = 'repeat_hh_id_82905168-0510-46e2-9b55-5306fc6ad709,d1f79a1e-2844-4c98-ac20-9f3ca0bd8df0', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

implement(id = 'missing_wid_82d018ff-0059-4bef-8226-dc048a41ee59', query = "UPDATE clean_minicensus_main SET wid='2' WHERE instance_id='82d018ff-0059-4bef-8226-dc048a41ee59'")

iid = "'b631e081-bb2c-4bdc-97d1-d6e73fd24e2d'"
implement(id = 'repeat_hh_id_b631e081-bb2c-4bdc-97d1-d6e73fd24e2d,9d1f5ef2-647a-4869-a108-a455e17669bc', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";")

# In the below, it appears they picked household head to be person 4 when it should have been person 1
implement(id = 'hh_head_too_young_old_47b88599-1e36-429a-b348-f24715c369c2', query = "UPDATE clean_minicensus_main SET hh_head_id='4' WHERE instance_id='47b88599-1e36-429a-b348-f24715c369c2'; UPDATE clean_minicensus_main SET hh_head_dob='1997-07-02' WHERE instance_id='47b88599-1e36-429a-b348-f24715c369c2'; UPDATE clean_minicensus_main SET hh_head_gender='male' WHERE instance_id='47b88599-1e36-429a-b348-f24715c369c2';")

implement(id = 'hh_sub_age_mismatch_young_47b88599-1e36-429a-b348-f24715c369c2', is_ok = True)

implement(id = 'hh_head_too_young_old_540f3603-4c2e-40a5-a60a-635be795a32b', query = "UPDATE clean_minicensus_main SET hh_head_dob='1994-12-12' WHERE instance_id='540f3603-4c2e-40a5-a60a-635be795a32b'; UPDATE clean_minicensus_people SET dob='1994-12-12' WHERE instance_id='540f3603-4c2e-40a5-a60a-635be795a32b' and num='1';")

implement(id = 'hh_head_too_young_old_a8f3a1db-efef-4de7-8b54-71958de9b156', query = "UPDATE clean_minicensus_main SET hh_head_dob='1996-06-15' WHERE instance_id='a8f3a1db-efef-4de7-8b54-71958de9b156'; UPDATE clean_minicensus_people SET dob='1996-06-15' WHERE instance_id='a8f3a1db-efef-4de7-8b54-71958de9b156' and num='1';")

implement(id = 'hh_head_too_young_old_9b53674d-70b4-4905-9e70-bda099ecec81', is_ok = True)
implement(id = 'energy_ownership_mismatch_81bbf5c2-0f3c-4b10-9970-930bae33f86f', is_ok = True)
implement(id = 'too_many_houses_2743fb87-a494-4a0d-8835-0fae53b543cc', query = "UPDATE clean_minicensus_main SET hh_n_constructions='1' WHERE instance_id='2743fb87-a494-4a0d-8835-0fae53b543cc';")
implement(id = 'strange_wid_enumerations_723f4a7f-f161-4739-80d5-8a3ee412023f', query = "UPDATE clean_enumerations SET wid='430' WHERE instance_id = '723f4a7f-f161-4739-80d5-8a3ee412023f';")

##### Xing Dec 2 Fixes #####

### Joe, please see below for updated corrections to DOB
# verified that only DOB incorrectly entered
implement(id = 'hh_head_too_young_old_b3fb8bbd-b526-4077-9d35-80e1b6065ebc', query = "UPDATE clean_minicensus_main SET hh_head_dob='2001-11-10' WHERE instance_id='b3fb8bbd-b526-4077-9d35-80e1b6065ebc'; UPDATE clean_minicensus_people SET dob='2001-11-10' WHERE instance_id='b3fb8bbd-b526-4077-9d35-80e1b6065ebc' and num='1'", who = 'Xing Brew')
implement(id = 'hh_head_too_young_old_6de39fda-146e-4e52-a04b-2270235bb4ca', query = "UPDATE clean_minicensus_main SET hh_head_dob='2000-05-07' WHERE instance_id='6de39fda-146e-4e52-a04b-2270235bb4ca'; UPDATE clean_minicensus_people SET dob='2000-05-07' WHERE instance_id='6de39fda-146e-4e52-a04b-2270235bb4ca' and num='1'", who = 'Xing Brew')
implement(id = 'hh_head_too_young_old_59227b76-b811-4060-8a72-e4ca544b8825', query = "UPDATE clean_minicensus_main SET hh_head_dob='2000-09-03' WHERE instance_id='59227b76-b811-4060-8a72-e4ca544b8825'; UPDATE clean_minicensus_people SET dob='2000-09-03' WHERE instance_id='59227b76-b811-4060-8a72-e4ca544b8825' and num='1'", who = 'Xing Brew')

# Fixed DOB. HH head is correctly identified in minicensus_main, but she was entered second in minicensus_people, so her permid ends in -002.
implement(id = 'hh_head_too_young_old_1cb51568-08f3-469a-944b-8eaff8324676', query = "UPDATE clean_minicensus_main SET hh_head_dob='1987-11-05' WHERE instance_id='1cb51568-08f3-469a-944b-8eaff8324676'; UPDATE clean_minicensus_people SET dob='1987-11-05' WHERE instance_id='1cb51568-08f3-469a-944b-8eaff8324676' and num='2'", who = 'Xing Brew')

# incorrect person selected as hh_head in minicensus_main, DOB correct in minicensus_people
implement(id = 'hh_head_too_young_old_aa24512d-d817-4131-9b66-c7e953558826', query = "UPDATE clean_minicensus_main SET hh_head_dob='1997-06-09', hh_head_id='1' WHERE instance_id='aa24512d-d817-4131-9b66-c7e953558826'", who = 'Xing Brew')

# Need to verify who is hh head. In minicensus_main, hh_head_id=4 but hh_head_dob matches person num=1 in minicensus_people. Corrected DOB is not similar to that of either person.
# implement(id = 'hh_head_too_young_old_2d9a7ce2-05f3-41b2-aab4-657f8abb3bdc', query = "UPDATE clean_minicensus_main SET hh_head_dob='1980-02-02' WHERE instance_id='47b88599-1e36-429a-b348-f24715c369c2'; UPDATE clean_minicensus_people SET dob='1980-02-02' WHERE instance_id='47b88599-1e36-429a-b348-f24715c369c2'", who = 'Xing Brew')

# added brick_block as additional wall material.
implement(id = 'note_material_warning_02f7a143-66a1-4118-a09d-2a2ea42f605d', query = "UPDATE clean_minicensus_main SET hh_main_building_type='brick_block zinc' WHERE instance_id='02f7a143-66a1-4118-a09d-2a2ea42f605d'", who = 'Xing Brew')


implement(id = 'strange_hh_code_enumerations_0ae1e05c-94e5-4055-b3eb-7171c56a65ff', query = "UPDATE clean_enumerations SET agregado='ZVB-088', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='0ae1e05c-94e5-4055-b3eb-7171c56a65ff'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_0ae45db7-8a6c-4e57-8304-8220516d837f', query = "UPDATE clean_enumerations SET agregado='ZVB-127', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='0ae45db7-8a6c-4e57-8304-8220516d837f'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_14e00292-ac83-4856-b20b-f8be4acfa5f4', query = "UPDATE clean_enumerations SET agregado='ZVB-120', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='14e00292-ac83-4856-b20b-f8be4acfa5f4'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_151b1d7b-076a-4efc-877d-3d536641d1c1', query = "UPDATE clean_enumerations SET agregado='ZVB-112', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='151b1d7b-076a-4efc-877d-3d536641d1c1'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_1ec1cc0f-2ba4-4c39-8680-d42d90705cc3', query = "UPDATE clean_enumerations SET agregado='ZVB-111', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='1ec1cc0f-2ba4-4c39-8680-d42d90705cc3'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_1eeb7a62-9ba2-408f-9fdf-3cd7b8e3507b', query = "UPDATE clean_enumerations SET agregado='ZVB-143', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='1eeb7a62-9ba2-408f-9fdf-3cd7b8e3507b'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_1fca01d0-59aa-469d-bfa3-6bd3fb64f859', query = "UPDATE clean_enumerations SET agregado='ZVB-135', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='1fca01d0-59aa-469d-bfa3-6bd3fb64f859'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_221f2169-8527-409a-8986-7bc721eed0b1', query = "UPDATE clean_enumerations SET agregado='ZVB-019', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='221f2169-8527-409a-8986-7bc721eed0b1'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_27e0ed84-2568-40c8-ace5-b2513105317d', query = "UPDATE clean_enumerations SET agregado='ZVB-144', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='27e0ed84-2568-40c8-ace5-b2513105317d'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_2fe96096-9d27-4971-a443-b96b445d714d', query = "UPDATE clean_enumerations SET agregado='ZVB-103', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='2fe96096-9d27-4971-a443-b96b445d714d'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_3188e32a-60a3-471b-bd3d-cb8f371b37c4', query = "UPDATE clean_enumerations SET agregado='ZVB-094', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='3188e32a-60a3-471b-bd3d-cb8f371b37c4'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_351a34e7-c0b8-4352-a893-3ea36f95ea48', query = "UPDATE clean_enumerations SET agregado='ZVB-122', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='351a34e7-c0b8-4352-a893-3ea36f95ea48'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_356a11d7-c0a6-4da3-875a-1c2c6fdd9ede', query = "UPDATE clean_enumerations SET agregado='ZVB-101', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='356a11d7-c0a6-4da3-875a-1c2c6fdd9ede'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_3b1a8f04-b6ef-49aa-bd77-3e37b54e7887', query = "UPDATE clean_enumerations SET agregado='ZVB-097', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='3b1a8f04-b6ef-49aa-bd77-3e37b54e7887'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_3dc39946-e2ef-4c85-8c99-463b42cfee0f', query = "UPDATE clean_enumerations SET agregado='ZVB-126', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='3dc39946-e2ef-4c85-8c99-463b42cfee0f'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_3f4bf1d1-3615-4f7c-96ef-609e3602a8cf', query = "UPDATE clean_enumerations SET agregado='ZVB-118', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='3f4bf1d1-3615-4f7c-96ef-609e3602a8cf'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_46af2d62-da53-4d3d-a822-90165c18e56f', query = "UPDATE clean_enumerations SET agregado='ZVB-145', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='46af2d62-da53-4d3d-a822-90165c18e56f'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_47eb26a4-7c51-47a8-b98b-141c91903516', query = "UPDATE clean_enumerations SET agregado='ZVB-109', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='47eb26a4-7c51-47a8-b98b-141c91903516'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_4a9c20a9-da7c-4ab3-8d98-0f78b82b0db9', query = "UPDATE clean_enumerations SET agregado='ZVB-106', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='4a9c20a9-da7c-4ab3-8d98-0f78b82b0db9'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_4fab82ef-ddc7-4c18-8fa6-bbf0fa4bbfca', query = "UPDATE clean_enumerations SET agregado='ZVB-108', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='4fab82ef-ddc7-4c18-8fa6-bbf0fa4bbfca'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_504b002b-b9a3-4af6-950d-817be8100433', query = "UPDATE clean_enumerations SET agregado='ZVB-102', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='504b002b-b9a3-4af6-950d-817be8100433'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_5767b7b0-1908-48f0-95cb-13e7e115ff21', query = "UPDATE clean_enumerations SET agregado='ZVB-116', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='5767b7b0-1908-48f0-95cb-13e7e115ff21'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_611e2e12-261b-4b26-9ee9-6e18019f2da6', query = "UPDATE clean_enumerations SET agregado='ZVB-142', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='611e2e12-261b-4b26-9ee9-6e18019f2da6'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_78d3d9f2-3e61-49b3-b222-7ba1459b63e0', query = "UPDATE clean_enumerations SET agregado='ZVB-079', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='78d3d9f2-3e61-49b3-b222-7ba1459b63e0'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_7b424c02-08ba-4d19-8df2-33c373f96127', query = "UPDATE clean_enumerations SET agregado='ZVB-107', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='7b424c02-08ba-4d19-8df2-33c373f96127'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_7c0cc306-4a63-4686-99cd-809c0b6d9ce2', query = "UPDATE clean_enumerations SET agregado='ZVB-083', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='7c0cc306-4a63-4686-99cd-809c0b6d9ce2'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_7e753048-7871-4d9c-b105-5145ea040bda', query = "UPDATE clean_enumerations SET agregado='ZVB-082', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='7e753048-7871-4d9c-b105-5145ea040bda'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_9e3c4936-906a-44d5-ab93-0ddabc9c0366', query = "UPDATE clean_enumerations SET agregado='ZVB-080', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='9e3c4936-906a-44d5-ab93-0ddabc9c0366'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_a0ad53eb-50de-451e-ab65-2b30f9b35cb4', query = "UPDATE clean_enumerations SET agregado='ZVB-105', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='a0ad53eb-50de-451e-ab65-2b30f9b35cb4'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_a4a75729-a627-4a78-8822-c82ae2d13260', query = "UPDATE clean_enumerations SET agregado='ZVB-114', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='a4a75729-a627-4a78-8822-c82ae2d13260'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_a4a909b6-461a-44b5-acea-025079482194', query = "UPDATE clean_enumerations SET agregado='ZVB-119', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='a4a909b6-461a-44b5-acea-025079482194'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_b11757be-5b39-4e24-bd5b-540fba0b63c1', query = "UPDATE clean_enumerations SET agregado='ZVB-123', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='b11757be-5b39-4e24-bd5b-540fba0b63c1'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_b3a2daff-ed70-4532-8f1f-b46f66b7b9c4', query = "UPDATE clean_enumerations SET agregado='ZVB-115', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='b3a2daff-ed70-4532-8f1f-b46f66b7b9c4'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_b62b9c32-6142-4570-a79c-a1af19d647e3', query = "UPDATE clean_enumerations SET agregado='ZVB-104', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='b62b9c32-6142-4570-a79c-a1af19d647e3'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_b9439bd1-cc98-40fb-9132-beebf1f8c630', query = "UPDATE clean_enumerations SET agregado='ZVB-081', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='b9439bd1-cc98-40fb-9132-beebf1f8c630'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_ba00a159-9421-4743-a7a7-1e7cfd20f17c', query = "UPDATE clean_enumerations SET agregado='ZVB-136', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='ba00a159-9421-4743-a7a7-1e7cfd20f17c'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_ba225282-cd09-4c11-ace5-836e1bbb45ce', query = "UPDATE clean_enumerations SET agregado='ZVB-148', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='ba225282-cd09-4c11-ace5-836e1bbb45ce'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_bf5804fd-dbea-44f9-86e8-062c37985279', query = "UPDATE clean_enumerations SET agregado='ZVB-147', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='bf5804fd-dbea-44f9-86e8-062c37985279'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_c0ae1321-9ded-4113-94f6-b7cb7b30f821', query = "UPDATE clean_enumerations SET agregado='ZVB-110', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='c0ae1321-9ded-4113-94f6-b7cb7b30f821'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_c64e7778-c77f-404a-bdba-6f71a25e3603', query = "UPDATE clean_enumerations SET agregado='ZVB-084', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='c64e7778-c77f-404a-bdba-6f71a25e3603'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_ca98802d-17df-43ed-8c6d-f0e4761bb915', query = "UPDATE clean_enumerations SET agregado='ZVB-130', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='ca98802d-17df-43ed-8c6d-f0e4761bb915'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_d01fa417-fa50-43a8-bb67-0fddbeffedd4', query = "UPDATE clean_enumerations SET agregado='ZVB-093', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='d01fa417-fa50-43a8-bb67-0fddbeffedd4'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_d16279f3-c204-4868-817b-d9ed36f028bb', query = "UPDATE clean_enumerations SET agregado='ZVB-131', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='d16279f3-c204-4868-817b-d9ed36f028bb'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_d25e9922-0169-450f-9cc4-c74064b06a50', query = "UPDATE clean_enumerations SET agregado='ZVB-095', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='d25e9922-0169-450f-9cc4-c74064b06a50'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_d7cba286-1ee1-4fbb-9ec8-1e59f6ddde1a', query = "UPDATE clean_enumerations SET agregado='ZVB-085', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='d7cba286-1ee1-4fbb-9ec8-1e59f6ddde1a'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_da4b615c-defd-4d33-9426-38154db3b180', query = "UPDATE clean_enumerations SET agregado='ZVB-128', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='da4b615c-defd-4d33-9426-38154db3b180'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_e4d6dc2c-2dcf-45db-b345-d760fc12816f', query = "UPDATE clean_enumerations SET agregado='ZVB-138', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='e4d6dc2c-2dcf-45db-b345-d760fc12816f'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_ec52f537-ec41-4dd2-aa29-6c89d2450b7e', query = "UPDATE clean_enumerations SET agregado='ZVB-125', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='ec52f537-ec41-4dd2-aa29-6c89d2450b7e'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_f49f710d-3320-4a6e-829f-792ee26cc8fc', query = "UPDATE clean_enumerations SET agregado='ZVB-092', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='f49f710d-3320-4a6e-829f-792ee26cc8fc'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_f5a84eb2-72ed-4c18-8062-1fc95febee4e', query = "UPDATE clean_enumerations SET agregado='ZVB-099', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='f5a84eb2-72ed-4c18-8062-1fc95febee4e'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_f96e671b-3891-4458-aba2-4d54eaf36bd3', query = "UPDATE clean_enumerations SET agregado='ZVB-146', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='f96e671b-3891-4458-aba2-4d54eaf36bd3'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_f97d7369-6c58-40c7-830d-614d07e20f6b', query = "UPDATE clean_enumerations SET agregado='ZVB-132', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='f97d7369-6c58-40c7-830d-614d07e20f6b'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_0ded8ad6-667e-4b0b-a3c5-4f72102d209f', query = "UPDATE clean_enumerations SET agregado='ZVB-003', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='0ded8ad6-667e-4b0b-a3c5-4f72102d209f'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_27cd6db5-f978-4de7-b00d-c1b3b0702778', query = "UPDATE clean_enumerations SET agregado='ZVB-006', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='27cd6db5-f978-4de7-b00d-c1b3b0702778'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_342c880e-881a-471e-b19b-0ed742d341b8', query = "UPDATE clean_enumerations SET agregado='ZVB-014', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='342c880e-881a-471e-b19b-0ed742d341b8'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_3470acea-5019-435e-8bcc-48bf178db6dc', query = "UPDATE clean_enumerations SET agregado='ZVB-010', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='3470acea-5019-435e-8bcc-48bf178db6dc'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_36ccda5f-f830-4d0b-8ecb-f0aaada44d35', query = "UPDATE clean_enumerations SET agregado='ZVB-008', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='36ccda5f-f830-4d0b-8ecb-f0aaada44d35'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_3be8b613-ace7-4d38-b8a6-c7f7a3e588bd', query = "UPDATE clean_enumerations SET agregado='ZVB-007', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='3be8b613-ace7-4d38-b8a6-c7f7a3e588bd'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_43966ca0-ece3-4b9a-83cd-9aed79bf1302', query = "UPDATE clean_enumerations SET agregado='ZVB-027', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='43966ca0-ece3-4b9a-83cd-9aed79bf1302'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_57a70883-ecdd-47dc-ac06-c5265d03ee3f', query = "UPDATE clean_enumerations SET agregado='ZVB-032', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='57a70883-ecdd-47dc-ac06-c5265d03ee3f'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_5e47e387-bb8e-4851-8864-03556a301414', query = "UPDATE clean_enumerations SET agregado='ZVB-012', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='5e47e387-bb8e-4851-8864-03556a301414'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_5ee6c7af-f7c1-4591-a3e1-9cc4ca9cd6f2', query = "UPDATE clean_enumerations SET agregado='ZVB-018', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='5ee6c7af-f7c1-4591-a3e1-9cc4ca9cd6f2'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_61353dde-017f-40b6-a4ad-ab1126a25978', query = "UPDATE clean_enumerations SET agregado='ZVB-004', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='61353dde-017f-40b6-a4ad-ab1126a25978'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_657c99fd-869d-4dba-a04c-3c5321bc60a7', query = "UPDATE clean_enumerations SET agregado='ZVB-017', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='657c99fd-869d-4dba-a04c-3c5321bc60a7'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_662b5a44-a54e-4b4e-8026-fe0bf4aa4d3a', query = "UPDATE clean_enumerations SET agregado='ZVB-021', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='662b5a44-a54e-4b4e-8026-fe0bf4aa4d3a'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_68036492-3913-4d99-adf9-00992cc60bb8', query = "UPDATE clean_enumerations SET agregado='ZVB-015', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='68036492-3913-4d99-adf9-00992cc60bb8'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_875c03dd-4553-4865-8976-07a22b0244b6', query = "UPDATE clean_enumerations SET agregado='ZVB-009', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='875c03dd-4553-4865-8976-07a22b0244b6'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_8b271c21-f98d-4eae-9868-f3e0f9998a9a', query = "UPDATE clean_enumerations SET agregado='ZVB-033', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='8b271c21-f98d-4eae-9868-f3e0f9998a9a'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_9034ab64-6140-4954-b5dd-a1c6fcde279b', query = "UPDATE clean_enumerations SET agregado='ZVB-022', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='9034ab64-6140-4954-b5dd-a1c6fcde279b'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_9b8421b9-00be-4baa-9cec-8d9b305d3422', query = "UPDATE clean_enumerations SET agregado='ZVB-030', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='9b8421b9-00be-4baa-9cec-8d9b305d3422'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_cb96e9e8-4515-41bf-a733-40bad0a19735', query = "UPDATE clean_enumerations SET agregado='ZVB-023', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='cb96e9e8-4515-41bf-a733-40bad0a19735'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_d4b739b5-3ca2-4c71-b062-9dcd1875afe4', query = "UPDATE clean_enumerations SET agregado='ZVB-029', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='d4b739b5-3ca2-4c71-b062-9dcd1875afe4'", who = 'Xing Brew')
implement(id = 'strange_hh_code_enumerations_e52419e4-efb8-4c94-adc1-6814009767a2', query = "UPDATE clean_enumerations SET agregado='ZVB-028', hamlet_code='ZVB', hamlet='Zona Verde B' WHERE instance_id='e52419e4-efb8-4c94-adc1-6814009767a2'", who = 'Xing Brew')

implement(id = 'strange_wid_enumerations_727cdf66-d41a-48bd-9526-fa8735655b30', query = "UPDATE clean_enumerations SET wid='428', wid_manual='428' WHERE instance_id='727cdf66-d41a-48bd-9526-fa8735655b30'", who = 'Xing Brew')
implement(id = 'strange_wid_enumerations_e8fbc7bd-ca44-4af6-b706-c0c072eddd13', query = "UPDATE clean_enumerations SET wid='424', wid_manual='424' WHERE instance_id='e8fbc7bd-ca44-4af6-b706-c0c072eddd13'", who = 'Xing Brew')
implement(id = 'missing_wid_enumerations_5819ed3e-618f-44e8-9d1e-a0bd31baff13', query = "UPDATE clean_enumerations SET wid='376', wid_manual='376' WHERE instance_id='5819ed3e-618f-44e8-9d1e-a0bd31baff13'", who = 'Xing Brew')
implement(id = 'missing_wid_enumerations_e2478e30-b318-483e-a0eb-be69a5318b00', query = "UPDATE clean_enumerations SET wid='436', wid_manual='436' WHERE instance_id='e2478e30-b318-483e-a0eb-be69a5318b00'", who = 'Xing Brew')
implement(id = 'missing_wid_va_21e66a54-5ee2-40af-8b67-0ceaf33a1fe0', query = "UPDATE clean_va SET wid='382' WHERE instance_id='21e66a54-5ee2-40af-8b67-0ceaf33a1fe0'", who = 'Xing Brew')
implement(id = 'missing_wid_va_ab45b465-93b8-4884-b03f-4615c5ea1af6', query = "UPDATE clean_va SET wid='367' WHERE instance_id='ab45b465-93b8-4884-b03f-4615c5ea1af6'", who = 'Xing Brew')
implement(id = 'missing_wid_va_ea7fb4ca-ee7f-4fb3-abd9-f46fa0c63fff', query = "UPDATE clean_va SET wid='346' WHERE instance_id='ea7fb4ca-ee7f-4fb3-abd9-f46fa0c63fff'", who = 'Xing Brew')
implement(id = 'missing_wid_va_76a3fecd-c548-40cb-837b-42f8d131d9f9', query = "UPDATE clean_va SET wid='367' WHERE instance_id='76a3fecd-c548-40cb-837b-42f8d131d9f9'", who = 'Xing Brew')
implement(id = 'missing_wid_va_83ce759a-3e04-49c1-9ddd-a2f1d73ffe47', query = "UPDATE clean_va SET wid='346' WHERE instance_id='83ce759a-3e04-49c1-9ddd-a2f1d73ffe47'", who = 'Xing Brew')

implement(id = 'energy_ownership_mismatch_7b369660-6605-4444-8eb9-0bc2204ad8f4', query = "UPDATE clean_minicensus_main SET hh_main_energy_source_for_lighting='electricity' WHERE instance_id='7b369660-6605-4444-8eb9-0bc2204ad8f4'", who = 'Xing Brew')
implement(id = 'energy_ownership_mismatch_17547c71-56b3-403f-aa80-14c20d974419', query = "UPDATE clean_minicensus_main SET hh_main_energy_source_for_lighting='electricity' WHERE instance_id='17547c71-56b3-403f-aa80-14c20d974419'", who = 'Xing Brew')
implement(id = 'energy_ownership_mismatch_9daa040a-949e-4b1f-b7d0-0d63600355e1', query = "UPDATE clean_minicensus_main SET hh_main_energy_source_for_lighting='electricity' WHERE instance_id='9daa040a-949e-4b1f-b7d0-0d63600355e1'", who = 'Xing Brew')

implement(id = 'energy_ownership_mismatch_12819949-e1a4-40ee-b4fc-e3f10d33ea8d', query = "UPDATE clean_minicensus_main SET hh_possessions='radio cell_phone' WHERE instance_id='12819949-e1a4-40ee-b4fc-e3f10d33ea8d'", who = 'Xing Brew')
implement(id = 'energy_ownership_mismatch_4170fa7a-e168-4287-9101-96f7d3a4b9dc', query = "UPDATE clean_minicensus_main SET hh_possessions='radio' WHERE instance_id='4170fa7a-e168-4287-9101-96f7d3a4b9dc'", who = 'Xing Brew')
implement(id = 'energy_ownership_mismatch_cdc973fe-ec43-47a4-bfdd-116384e8106c', query = "UPDATE clean_minicensus_main SET hh_possessions='radio' WHERE instance_id='cdc973fe-ec43-47a4-bfdd-116384e8106c'", who = 'Xing Brew')

implement(id = 'energy_ownership_mismatch_bf995b59-6c68-4b9d-9fef-f6ce60b3bd8b', query = "UPDATE clean_minicensus_main SET hh_possessions='none' WHERE instance_id='bf995b59-6c68-4b9d-9fef-f6ce60b3bd8b'", who = 'Xing Brew')

implement(id = 'all_males_17547c71-56b3-403f-aa80-14c20d974419', query = "UPDATE clean_minicensus_people SET gender='female' WHERE num='2' and instance_id='17547c71-56b3-403f-aa80-14c20d974419'", who = 'Xing Brew')
implement(id = 'all_males_e57b0474-c749-4d3f-ab2d-b3148320408c', query = "UPDATE clean_minicensus_people SET gender='female' WHERE num='2' and  instance_id='e57b0474-c749-4d3f-ab2d-b3148320408c'; UPDATE clean_minicensus_people SET gender='female' WHERE num='5' and  instance_id='e57b0474-c749-4d3f-ab2d-b3148320408c'; UPDATE clean_minicensus_people SET gender='female' WHERE num='8' and  instance_id='e57b0474-c749-4d3f-ab2d-b3148320408c'; UPDATE clean_minicensus_people SET gender='female' WHERE num='10' and instance_id='e57b0474-c749-4d3f-ab2d-b3148320408c'", who = 'Xing Brew')
implement(id = 'all_males_00a08a44-7318-412a-b7d2-744f16d89021', query = "UPDATE clean_minicensus_people SET gender='female' WHERE num='2' and instance_id='00a08a44-7318-412a-b7d2-744f16d89021'; UPDATE clean_minicensus_people SET gender='female' WHERE num='5' and instance_id='00a08a44-7318-412a-b7d2-744f16d89021'", who = 'Xing Brew')

implement(id = 'repeat_hh_id_3e4ee729-ec87-48a9-8582-ab4f08c903ae,e070ae02-d694-4b3d-b8f2-7abec455bbb3', query = "UPDATE clean_minicensus_main SET hh_id='CUM-012' WHERE instance_id='3e4ee729-ec87-48a9-8582-ab4f08c903ae'; UPDATE clean_minicensus_people SET pid='CUM-012-001', permid='CUM-012-002' WHERE num='1' and instance_id='3e4ee729-ec87-48a9-8582-ab4f08c903ae'; UPDATE clean_minicensus_people SET pid='CUM-012-001', permid='CUM-012-002' WHERE num='2' and instance_id='3e4ee729-ec87-48a9-8582-ab4f08c903ae'; UPDATE clean_minicensus_people SET pid='CUM-012-003', permid='CUM-012-003' WHERE num='3' and instance_id='3e4ee729-ec87-48a9-8582-ab4f08c903ae'; UPDATE clean_minicensus_people SET pid='CUM-012-004', permid='CUM-012-004' WHERE num='4' and instance_id='3e4ee729-ec87-48a9-8582-ab4f08c903ae'; UPDATE clean_minicensus_people SET pid='CUM-012-005', permid='CUM-012-005' WHERE num='5' and instance_id='3e4ee729-ec87-48a9-8582-ab4f08c903ae'; UPDATE clean_minicensus_people SET pid='CUM-012-006', permid='CUM-012-006' WHERE num='6' and instance_id='3e4ee729-ec87-48a9-8582-ab4f08c903ae'", who = 'Xing Brew')

# test records to be deleted, unsure if there are other databases they need to be removed from as well:
implement(id = 'strange_wid_enumerations_53fad9f3-a31b-48d1-a582-8e66523580b0', query = "DELETE FROM clean_enumerations WHERE instance_id='53fad9f3-a31b-48d1-a582-8e66523580b0'", who = 'Xing Brew')
implement(id = 'strange_wid_refusals_183d99cd-09e0-4638-b0bf-553abb21fa8f', query = "DELETE FROM clean_refusals WHERE instance_id='183d99cd-09e0-4638-b0bf-553abb21fa8f'", who = 'Xing Brew')
implement(id = 'strange_wid_refusals_d1ac8f57-8c55-43ad-a9e8-a294053c58fd', query = "DELETE FROM clean_refusals WHERE instance_id='d1ac8f57-8c55-43ad-a9e8-a294053c58fd'", who = 'Xing Brew')
implement(id = 'missing_wid_refusals_ab2ea7af-cec2-4b5e-9e5d-b636d395fbb1', query = "DELETE FROM clean_refusals WHERE instance_id='ab2ea7af-cec2-4b5e-9e5d-b636d395fbb1'", who = 'Xing Brew')

# Removing enumerations at site request
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='02720e92-ddfe-455c-9ac2-74a8342a17ab'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='08f37dca-90f1-48c9-a3c8-00b68cd273aa'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='0a8a164c-7f28-47e6-b24e-884a9ec1166a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='0f043162-623a-47b6-a378-6ad3cd4b10d7'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='11cfd8bb-c7c9-40e7-b5e8-a6193c48a56a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='130dd196-2e0c-4aea-a99f-a03958eafbb4'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='143eb4c4-682b-4a1a-86de-072775b824e3'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='19dc2605-66f3-4b85-aa44-9bd6c70b6a22'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='24af7096-7401-434c-9569-5cdb507c25b9'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='28532fd4-6e08-417a-be3a-470d440fca6d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='329cf78d-ac18-4eb8-8c50-6cda09f0f130'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3a0af05f-61b5-4cde-8ad6-c4d96b7961d9'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3c1cd1ea-0a75-4b5b-8c98-ccf78dc72f94'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3d52d4d8-650e-4344-8b59-b1c1fcd59363'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='547139cd-4f3e-4b48-98f2-c537b796cc47'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='56da06b0-4aea-427f-ab00-9e135295eb35'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='587c8307-ac2f-4c45-8aef-3fb3fd8445f8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='5bbd1592-9050-4d72-ada1-0fdea77fd36c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='64366cd7-e14e-40bd-ad6c-d86bf716e8b5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6a72adce-3855-4aa7-ba90-10244ea1eb37'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='74ced52b-a9ae-418f-b046-0706c5987017'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8bcd8fae-dda7-494b-82c8-eb1c4f6a44da'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8f28e42d-ddbd-401f-bce0-45780184eafb'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='99b11b10-dc59-4517-9304-6bab982a7252'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a70cb6a1-7d4f-44ae-8397-16ffe4d9ebcb'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ad1ceb67-1021-4b56-98f1-d6244f198ca2'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b216bb17-f3e3-417d-a077-19d5d749184d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='bbd8495e-b318-41ba-b16d-a7126c81ff6f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c74269ed-4368-4c8a-98e7-e97c2150b04b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c7fdd610-30ee-4ce5-adc6-f2ee74d31bd2'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c92eda6e-e176-47b7-89a1-ffd289c6269a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='cd33aa09-a7be-4d95-b400-6db46690fa86'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='cf767dbd-f19e-4cb7-9723-a2e26cc3aa42'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='d1c3565a-3e91-4604-bb0b-b2f0a0cc6888'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='d6c94b41-cd8b-489b-abc5-7feb499c85cc'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='dc3602b9-a929-42c4-acdd-614a893907c7'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='dfc7583f-3a3a-4048-ae5a-e47a5f7b2902'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e50f61d4-b6bd-45a5-b863-05a76fee8320'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='efbf39f5-46b0-42ce-80ae-9c49477cc147'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f0cb9510-4160-4b4b-8fde-92b0a0539eeb'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='fb3c301e-a9ec-4ab5-8e04-a55be60e4a37'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='00abd9be-9a4c-4c68-9067-865118f9f3f5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='00d4f282-4cf8-4738-b299-866bf026aca4'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='019b4608-271c-446c-b9c3-20e9030e0d99'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='020dc42e-6054-4895-b540-0564b9bed99d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='0280d8ba-535d-409a-9f62-18ff30f532f5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='029144bc-7b81-48b4-88a6-abf7560f895a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='051cc4d2-f470-4f6d-96a0-2a5228cf2bf3'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='05bcea1c-ff39-4e23-95ad-6dc8e0c14e5f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='07ceb19b-1b7f-4578-9f02-26a03d03cd8d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='0c96c3cb-c13d-4c31-83df-0b4b36802d70'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1094286c-d9e1-419e-a229-5f4040495520'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='112a707b-8336-4e37-bd93-069971e2c185'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='123bc7d2-4fa2-4041-ab2d-9b970dd5d69e'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='15dd8d05-ac93-470f-be72-1b9c57016599'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='16a59757-3535-4cb0-80e2-dd3afa620ce8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='17a325dc-d704-408a-bd61-251412a3b913'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1aff20ac-b27f-4869-a768-38badda88f68'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1e8f0103-5665-471e-937d-3984364a0643'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1ec40468-bf27-4b8b-a627-2e89cddfaebc'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1fed2a14-25a6-4c27-99e6-5874ccb8609a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='20f13280-9881-47d1-bdc1-4e8d611b8b86'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='26739a06-9746-46aa-92ac-6d6e5477bd56'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='28d729ba-c640-4907-aa79-b30ebbe2c44c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='2a7282e9-e2f1-4e9f-b202-6c826963c6a2'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='2ab85d08-7b94-469d-b42d-17d2ef55aec1'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='2c3660da-2594-46a6-a026-d12a8cbca244'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='2cb3a3b7-c9d8-4ea4-ae6e-1d412c6c6848'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='2d684bc2-3d19-47ae-8a55-e3bde3375419'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3000b788-a08d-4485-9333-955803f03f19'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='315547cf-ac7b-4a7e-abf1-11f11ecbe321'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3548c7e0-c015-4637-ad92-c52ce1e309fe'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='354da14b-470d-4bfc-b408-0a15db1a0aaa'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='362379cf-5eb4-47e5-a470-519e0f5ae2cd'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='367c9a2c-6b50-49d6-a84f-54a6e294c449'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='36f55cea-69b6-4b0e-bc51-92a816ee7ebe'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='373e25ec-0d32-4d0a-b19c-2ebb827223c7'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3836a5c1-7b9f-4b71-8eee-c9ac98537522'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='38824f93-0320-4522-a760-df0b58c7b2f4'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='39992f5f-fff1-4304-9052-363a859b11b8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3b62e948-ce87-495d-b05b-8f8a6ed2c61c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3cae4b5a-63a9-4eff-a067-fc6086fc8d72'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3f14ac77-2c15-46f4-8615-32cef9432f6f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='44ae5897-6a24-4cb2-9000-62fa7dd5283c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='44fbb43c-0883-48c5-9058-fc75ebcf21ea'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='46b661e5-2bef-46aa-ad37-8ad6284f055a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='49706481-f872-45f4-b4de-dd5c1bc50c30'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='506cf948-2a78-4fde-b49a-5ca92674e7b1'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='50a38c61-7774-4426-ba0f-ebb1765ac621'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='52658e27-5955-49e3-ab57-1b6590adc138'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='53a8af08-10cf-488f-aeea-e3c61cf17a98'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='54c77064-b0a3-462c-a8e2-403abd2893b5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='551b27b5-9149-4099-9b6d-23980b70bf9f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='56547492-3682-4215-b2ae-c7bac12d89c9'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='59284a9c-b989-4516-9a01-e8cb4da28090'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='593525d7-6d08-43b8-afa8-1951041c87a5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='5b36690f-b334-4879-87d3-950dd682fa55'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='5bf76c0f-f02b-495f-a719-e596a269e3bb'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='5daa37a4-f3f3-4cfa-8204-fc1a27aedf2c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='620e9ca7-1131-4205-999f-c1753669d061'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='63db3f83-e890-41cb-b68c-6861df88613b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='64fadf8f-03a9-4007-97f0-cfe8cc2d9d9a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='66b55596-8181-4f51-b0cb-cb8bfedf79a5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='67c9b055-9b8a-405a-8b88-1a172f4fe42a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6976b683-2809-4fe9-bdc7-235468efbd98'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6c851a89-215b-4736-8c90-ccfacda92841'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6cba3a77-5d40-44c8-8b74-2949ffad2b77'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6f3c7aae-52bd-4a17-95ef-b86b3286a16b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='70580a66-bd26-4334-914c-af14e0d8e544'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='741d8428-801a-49fc-ae23-b0f3af6c6589'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='74b1a36f-a292-48c3-adda-afaa9fa7f600'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='77941132-8a1a-4896-b998-780ff6ab5148'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7a7270d1-93c4-4429-8241-9f24fc62d9d9'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7c1a93fd-fd78-4eda-b71a-b6a54f72482b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7c513134-8683-40a4-ac74-a69d83401d61'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7e2cd911-2eee-49cc-b704-df052a73e2b6'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='804c5d0f-54e2-47ea-8e6f-ffb5497a5eda'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='829323cb-a1f6-4280-bb94-4c385ad08f5d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='864d9630-8457-45db-b7ea-702c65046632'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='876e5f19-46d3-4da3-8a60-753025d061b0'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='88cf2292-d2e7-42e0-9d33-3e805ed4267f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='88f20085-fc81-4d67-987c-f75ac9e7fbd6'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8ae5c6f5-e1ff-4e8d-8a41-7c65ba88afd0'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8d0c6387-8c23-4e3a-af1b-b32dd78cd98a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8d5c5642-6d3a-48d4-898d-eab7c3d673da'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9021e1a3-7582-438c-9f5c-a1586faeac85'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='915e50a7-f126-45ab-b4c4-7d2352fcef2c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='92006471-2193-413e-8afe-be8766619525'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='92d5e667-0a36-4023-a658-c1bcf296d208'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='936b61fb-01b5-4b44-8ae5-608e50829941'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='956da7e3-9dff-4592-a00f-aa0df4c405ea'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9650a1b2-fb4e-4960-94f3-f7a97db6b756'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='97d41051-5ed1-4d4e-b47c-ff84a7c72535'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9836c55f-e2c8-4fb6-aa35-b5801215d00f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='983d213b-f927-4436-af9d-84b21a948432'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9ab16c24-7dc4-4b24-ae47-6e23d9ab9abe'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9c18ec87-2c4d-4e69-9c7b-d6529242073b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9ebe26b1-1089-472b-b19a-3ae5916bc332'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9ed7cfdc-e470-42ce-a36e-ae2b96d8bbc8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a1cb5b4d-e8ca-4d29-a86a-8423a2483b0b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a5a9d487-f076-4490-a44d-330952ea7067'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a66bbd1e-0867-42df-8d17-62fd9e2de097'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b19189d7-edf6-4a9a-95d4-3ff2129ff603'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b24a0dfb-6b48-4186-943d-482f2cb0c22b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b2fae474-f19c-41d3-8493-a997bc73f0a1'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b527756b-89f8-4985-b97a-e0c170d6aef3'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b5bc913e-6caa-4793-a3d2-fd7b011eb05a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b7f61a6c-743c-40a6-b2ae-5d10ddb923f2'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b8c7d786-2d86-4124-9ad3-8cb72322fca4'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='bc6ec263-93d9-478b-847e-fd59de05644e'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='bd11cab5-8df9-468c-a522-bf40cf123cf2'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='bdb6a241-6ca8-49a1-bf30-7b1ec6ab4d1a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='be3a6e8a-4c62-4468-9a7e-d3ae6d1e76c5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='bfdb0704-b6c0-4d2f-809c-66c73827c4e1'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c0ae8cf4-b1e9-4041-81aa-8455aa4a5e88'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c1c604b5-a308-41f2-b5c0-c729e391a19c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c345875a-83eb-4dc3-a38a-061c3c8def2c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c40436df-185f-4300-9d20-fb1f2e61655e'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c6b4291d-35ac-4c33-b487-c2289890dd6b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='d0144684-f4bc-413d-af05-3da0ce83f95d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='d80b478a-ebd0-4dad-8258-3ff742ee2125'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='d9d4ce4e-1ad5-43da-be38-b388e58be676'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='dd09b512-6c52-4b54-b153-4d8d91020dde'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='dfbc50f4-cf44-4ca6-9950-10f21759b688'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e0ac50eb-c3be-4c8f-a657-d4eaefde7b87'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e2de998d-ee36-49b9-a10a-131d6b9611db'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e8875b8e-4638-4c6e-8afc-c0766999cc9f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ebacfa1d-f62b-4eab-a2d3-c1769b8bd5e5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ecc594e2-dbc9-46d2-a95e-dcbb8904a86a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='edf84a5e-48c4-4277-8f9e-2cace4ee5621'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ee3a2c98-1703-4f3f-90a4-ffba3a189477'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f037add0-d839-4924-b471-2ba65a059ec0'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f0c8eb24-8dcd-4d5d-89fa-df97e70ba49a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f9039d4c-4ec7-4b7c-b103-b9331ff35151'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='fba706b6-9d56-4c2b-89f8-efa4070ab5c3'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='fca68a8a-60bc-43f7-8683-373432e82f99'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='fd694b29-3a65-4fc6-9110-bff00098940f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='fd6ddcd5-c8af-4651-940e-7355efc8c5a5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='01826bbc-f519-4ea4-a58e-23053d27c6f0'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='077b833c-d2a6-41a8-bae2-03e1ccbbd294'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1432f21a-fa3a-4fb6-920f-7b3f4091f859'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='148d8cea-c44e-47a8-b5c9-621bc292ad2c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='15d30c82-7acf-42a2-b120-0edf98aba9e0'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='50deb336-99fc-46f0-94b4-2182057f6b76'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='60c61825-4ffe-4e25-9bf5-9d918f6de353'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='789ebeb8-2034-41a0-87e3-957fcbb65222'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='82a1acde-0efc-45ed-92fa-f109173f7248'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8edeb2e7-eeb6-47b9-a898-e93d631b8a01'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='99fa1128-e034-46bb-8e3e-daabdeadbc6e'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a491482b-1752-4514-99b6-467f73856f32'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='afb93c8f-d8d7-40d2-92fc-b36877c7ec2c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b0a7f00d-8bd7-4171-a70a-86966df1ea8f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b0e5dfef-5267-47f0-b64a-6c9c14c7b025'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c085241b-b3b5-46e8-8dbd-1456d59eb5ae'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='cda1c471-a12b-44d9-9c12-ff428186e21f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='dc30c18c-fe89-42d8-b879-877dd910ed98'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='de94d4de-4d50-4a74-9ab0-4fc9bb0abd5f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f28dd34c-3997-4274-9058-f89910d4254b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='027c6f94-811e-4220-9006-89be5752b4de'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='032674a4-74b7-439b-9b16-9ae534bf489d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='03a7b6de-b9aa-487d-ad53-15720bf85876'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='04c9529b-870a-4d99-873e-70fa946ea8ee'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='0ccbdc72-137a-45ca-b9c3-f510386f4d48'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='0d4a8614-7501-445e-970f-e6edf91dc34b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='0e6a0ef7-87ea-43bb-b71c-8ee14cd82b7b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='10423d3a-7823-4cd3-9536-8f381b99afef'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='12928af2-f496-4ff4-b5bc-d56ea9a800d5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='12942533-4c02-4704-8d94-999643e358f5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='12b54674-efc2-4216-8495-11374acc3d2c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1476dcb8-eec4-4c50-89e1-4c9f3c017835'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='16982623-6629-40d0-a8c0-4347fc5e26ad'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='17ddf86b-078e-4852-bf87-67cb3424bc01'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='19940579-6093-49d2-946d-5f81da3bcc65'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1c3956d7-a4cb-400e-8ea2-b162b28b83ca'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1c91a73b-33f5-44e3-bbf1-4fda48962611'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1d83f43d-4da2-4dc8-99f2-904746e3cb3f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1e13a715-a29b-4682-a52b-da7f5118663c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='1f2a1c20-7f31-4174-a1f3-9844204d72e7'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='20b3c53e-16a7-47d0-9154-c5c14af727e4'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='224ec614-739e-4eda-9332-12f709f55b87'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='24d398c0-8659-4fb9-a301-c12b3a1b5c45'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='24ed96fb-478d-4a64-9660-37c302832abc'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='32e75de5-345e-4ebf-8c2a-1912cabb1d6e'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='336f4705-866a-436b-9c37-9f7fdb58154f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='37da5b8c-ec9e-48d1-814a-5a991208ca67'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='384e17a7-f7d6-4785-bc05-50ef5577332d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='3aa0394a-dead-414b-a778-a524d1c19406'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='425c5b98-402c-4e3f-96a3-489072efe817'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='429f8162-fbc1-419c-bf2a-a2ee7127f195'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='45227317-cab7-42bd-994b-4f6c038e8936'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='455ca77f-6e2e-46d8-af59-de9de317adad'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='469efad9-f38c-4309-8fe1-0afbf4d5ff42'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='46fd2764-c3d1-42a6-ab5c-bbe908443058'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='4899d363-7423-4535-9ad1-9532eaa7d2d5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='49e21a3c-3f61-4308-b2d9-8241b3eb09fd'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='4a7ec965-cae8-4f73-b865-6d313ef89077'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='5005ac3d-1282-499c-9cf1-375bb23e4449'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='50381b98-6f82-4f27-88a0-9caace146f15'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='55635769-a689-4e83-87a2-1591a111e81b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='59a5254c-8645-43ca-83ba-584849a04d41'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='5cd5199d-6c48-41b9-8601-32f306f15820'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='678eedec-bce4-4440-96c7-79017ccd60d3'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6b805d98-cbcf-49a0-86d8-17afe68b19ed'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6e156247-f61c-4a3b-a813-f519614880dc'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6efaf33a-93fb-4aeb-9134-943520d73652'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='6fbe72ec-2cc4-4e18-8d4a-f4076d31380f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='71d4c36b-66c5-4d2c-8429-a91d05520887'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='72760ace-53ce-4d3f-a456-acabe4801bbe'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='76ed1008-9507-45d6-8a96-3d3a1a8026a7'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='77b22a77-3235-485f-9b00-5e3846d3259d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7860f0f1-caa0-4dc8-b16b-be267a1232c8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='79743b35-43a1-4b3f-b26c-256fab141ce0'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7b1ea63d-f7fb-4f53-99e3-c2b428636a98'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7b39b72e-9937-4a1e-a0db-3be541f56e03'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7b601dcc-7eae-4ba0-bf6b-5a15807f52cf'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='7bd97025-5644-4b3f-8f9f-bc556f31b477'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='82c2594b-917f-4e52-aa43-daabeb4e4b78'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='832ccbd9-8946-40e7-b9f9-f68d2af62cfc'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8348f308-17a8-40cd-92c1-69d5c9e1f3a7'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='834c9f14-6bab-439a-ad36-1a133ccaac00'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='86487053-b2cf-4b2b-8a44-0f03543ea688'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='866d73d5-aa71-4bdb-a4a7-72c8e53e8127'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='88518e2b-0365-4a12-a2ac-cbd453be39e8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8a5fd300-991b-4e4a-8e92-56d060eaefb9'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8bb2cfaa-07e1-4f6a-974f-3f70214d4b1c'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='8e63bca0-2b60-48a6-ba82-32883d918dec'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='90703679-7dc7-4a1a-931b-2f06d7e42508'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='907f8e78-3ad2-4062-b860-83861763a89e'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='91592f38-99a8-43da-9768-e46b6f806b58'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9184a432-1567-4f9c-89ae-9ddb3f2aa043'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='926d5412-d4b9-41d2-9ebb-8e3a72a34088'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='93baf162-35db-4358-b9f5-9705668b3fb6'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='977f49be-5d8e-4748-9bf1-771de63c61e5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='98f2231f-4046-46a2-b2df-a5637d9ae81f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='9af5515f-2aab-4421-a6c2-e39ec3f7bbfa'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a08d829f-b3cd-4c99-8071-bcdb977b50e9'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a3e13380-7761-4240-8ee2-8ece6fe3e26a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a410306c-f169-4f30-8291-67a219b12370'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='a53185b3-8f6a-4be3-8613-27be05118b01'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='aa831a8f-e822-4b29-b813-260b08ae222b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ac7a85fc-a4cc-4e61-9670-a5d9d07375ed'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='afb1eea7-dd54-4329-9fb4-216ffb5d06d6'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b0b28828-a256-426f-9119-837f68d71fc0'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b538161a-3bcc-44c6-bd90-e2832bad72ae'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b5ea5b0d-66e5-4774-bf2f-80a0984c9a18'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b60756d2-6982-422f-a948-79080606aafd'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b6b987ab-e737-4993-9c7d-35d655a56217'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='b9eb2bf4-3f8b-47aa-b0d9-f2e09614bc5e'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ba22b679-0dde-450a-ade4-a8056dd8a2e5'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='bb8205d5-fd58-47ff-9d0a-e7178834c34b'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='bca54588-3968-44b7-9a82-2600be9d1451'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='bdf0196b-f39c-42b9-baf1-0cd20629ee9f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='be2f9471-c21c-41b7-8ba0-6266c5b5ec33'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='be936d7c-fe86-4da8-953f-c4b3c36d3116'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='c02e5291-8b7d-422f-b2a9-eed0ce26cd46'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ca5374cf-918a-48b0-bf69-ebc12e53e4ca'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='d0a66b0f-a591-4fb4-b334-46550a329d85'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='d34db697-4c05-4667-a594-c51d881f751d'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='d835c7d8-5e2d-47fd-b542-37bb661a9e34'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e179218b-24b9-47a5-a1ce-9fd8901780c8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e3314347-c34e-40c1-aa24-38e03f569bb4'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e71ef654-396b-4ee5-8730-dd01b87335f3'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e8fbc7bd-ca44-4af6-b706-c0c072eddd13'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e9a39131-2949-40a6-b915-b34602cadf2f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='e9d108e8-462d-450d-b135-63e0f65a9362'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ec195139-0413-4f3b-95ae-77c7db4f3330'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='eca3687d-ecab-4cfc-bcf0-8f5af30f91c7'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ed00f9de-b917-4241-b8c5-e05be413d030'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ee802b4a-e9f9-4457-8f51-15a835847fae'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ef6d77db-7f0a-43db-87d8-a7132d4ab868'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ef9a4880-a225-4ae6-8c72-36b6e7024998'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f0da5c81-b39a-49f2-9a77-6a1879af8447'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f0e122e9-7269-403c-8c34-e8923502f24f'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f11d2cf1-bfdd-445d-b2a5-c681245c4e9a'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f16b951c-b61e-4090-acdf-b66cee4a1451'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f3d535fc-fe4c-4faa-a9ea-607b268f7ea8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f545f773-f426-4f26-bc91-26dfdf211a97'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='f6b221a3-ba06-4d42-ad9c-250fa6c7cbe8'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='fd797b50-0ee0-4d30-b4e9-4ebe45e554be'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='fdce285f-325f-40eb-94dd-8fd9f3d795aa'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='fe2acd0b-0a54-4ffc-9150-9ae45e76dc68'", who='Joe Brew') #manual removal at site request; going to re-enumerate
implement(id=None, query="DELETE FROM clean_enumerations WHERE instance_id='ffa1bd93-5c82-417d-9afe-8e4608da8052'", who='Joe Brew') #manual removal at site request; going to re-enumerate

# xing dec 10 fixes

iid = "'74ee26df-7b7a-4996-b0a7-f8f98fe0d2c1'"
implement(id = 'repeat_hh_id_74ee26df-7b7a-4996-b0a7-f8f98fe0d2c1,b5bdba25-bdde-4402-a062-b9c620153106', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'fcf91670-9792-48c3-b47b-c12462ad2bbe'"
implement(id = 'repeat_hh_id_78354fc9-dcc6-4adc-acaf-8fdaf09e6c35,fcf91670-9792-48c3-b47b-c12462ad2bbe', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'82731e78-1738-468b-8dd2-00a3035959e6'"
implement(id = 'repeat_hh_id_82731e78-1738-468b-8dd2-00a3035959e6,fddb150e-e4c3-455d-97ee-51c0ba987937', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'fddb150e-e4c3-455d-97ee-51c0ba987937'"
implement(id = 'repeat_hh_id_2457d2ed-7a12-486a-be74-4b5ff75dd3ba,2d669427-1c23-4916-99ad-821519360556', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'2d669427-1c23-4916-99ad-821519360556'"
implement(id = 'repeat_hh_id_2457d2ed-7a12-486a-be74-4b5ff75dd3ba,2d669427-1c23-4916-99ad-821519360556', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'bd70fdcf-8384-4610-946b-b50ba62415aa'"
implement(id = 'repeat_hh_id_8731cee3-09d8-47bb-a4d1-176eb95185eb,bd70fdcf-8384-4610-946b-b50ba62415aa', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'5a686230-9788-4476-a2e1-9379adfdd5ea'"
implement(id = 'repeat_hh_id_5a686230-9788-4476-a2e1-9379adfdd5ea,cdb929d2-a354-439d-8830-3e464c9ce927', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'fd8faeea-4016-4576-ae5a-c7da1a36ea58'"
implement(id = 'repeat_hh_id_b601262b-3533-4b14-af74-5d81ee108008,fd8faeea-4016-4576-ae5a-c7da1a36ea58', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'e5bfc22b-d780-4cea-883e-15c46275bc3e'"
implement(id = 'repeat_hh_id_0919bb03-5e89-454f-b5bc-0a8791bdf75c,e5bfc22b-d780-4cea-883e-15c46275bc3e', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'29818fa4-0961-4c9a-8f63-2181afac9f56'"
implement(id = 'repeat_hh_id_29818fa4-0961-4c9a-8f63-2181afac9f56,3870d967-0db5-49b0-8a53-c5f3d27e042b', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'0497dca6-c8d0-4069-9d12-9df3d9ff94c7'"
implement(id = 'repeat_hh_id_0497dca6-c8d0-4069-9d12-9df3d9ff94c7,788a5d06-1132-424c-acb9-d0653e0e7e0e', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'b37f6415-00bc-44b1-9312-e69a7940bbd6'"
implement(id = 'repeat_hh_id_b37f6415-00bc-44b1-9312-e69a7940bbd6,8a98ee9c-5890-438a-8433-6f2a252e7a38', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'16273b25-8f49-4bf7-8c9d-ecac2d2c423d'"
implement(id = 'repeat_hh_id_4d81af5f-2d30-4fa6-a1df-c6584abcee07,16273b25-8f49-4bf7-8c9d-ecac2d2c423d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'44328ed2-0d49-4ba0-a634-38376c51616d'"
implement(id = 'repeat_hh_id_6e335da3-f6b7-4481-8179-4f8324559c8f,44328ed2-0d49-4ba0-a634-38376c51616d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'216d2a9a-ad0c-4765-affe-a7155fff6e9b'"
implement(id = 'repeat_hh_id_a12603e5-0333-4a85-9804-6ea15f6af454,216d2a9a-ad0c-4765-affe-a7155fff6e9b', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'92af091d-0ced-49fa-9eb6-598055aba177'"
implement(id = 'repeat_hh_id_92af091d-0ced-49fa-9eb6-598055aba177,b0e7001d-3a70-4115-8c3a-087318b2b327', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'780ad7b9-9c9e-40b2-853f-006a0fc2ec93'"
implement(id = 'repeat_hh_id_fcd4134f-d5db-461f-85e2-97ccaa222657,780ad7b9-9c9e-40b2-853f-006a0fc2ec93', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

# deleting two entries in one implement
iid = "'ebc90642-cfec-4921-bf97-7ffd26c8ce53'"
iiid = "'b12c95c3-6180-4263-a236-1ce8d9b32d9e'"
implement(id = 'repeat_hh_id_ebc90642-cfec-4921-bf97-7ffd26c8ce53,b12c95c3-6180-4263-a236-1ce8d9b32d9e,c5b68e6c-bdb6-47c7-8d9c-2546e090af29', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_main WHERE instance_id=" + iiid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iiid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iiid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iiid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iiid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iiid + ";", who = 'Xing Brew')

# deleting one entry and updating the hh_id of another in one implement
iid = "'433897f6-ff8b-41bd-8cf0-075c2737ee7f'"
implement(id = 'repeat_hh_id_433897f6-ff8b-41bd-8cf0-075c2737ee7f,7d7de909-c27a-47ce-8706-e3649ea19c03,e24c430f-e62e-4dca-83c5-0efe00f7379e', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + "; UPDATE clean_minicensus_main SET hh_id='DEJ-116', hh_hamlet='24 de Julho', hh_hamlet_code='DEJ' WHERE instance_id='e24c430f-e62e-4dca-83c5-0efe00f7379e'; UPDATE clean_minicensus_people SET pid='DEJ-116-001', permid='DEJ-116-001' WHERE num='1' and instance_id='e24c430f-e62e-4dca-83c5-0efe00f7379e'; UPDATE clean_minicensus_people SET pid='DEJ-116-002', permid='DEJ-116-002' WHERE num='2' and instance_id='e24c430f-e62e-4dca-83c5-0efe00f7379e'; UPDATE clean_minicensus_people SET pid='DEJ-116-003', permid='DEJ-116-003' WHERE num='3' and instance_id='e24c430f-e62e-4dca-83c5-0efe00f7379e'; UPDATE clean_minicensus_people SET pid='DEJ-116-004', permid='DEJ-116-004' WHERE num='4' and instance_id='e24c430f-e62e-4dca-83c5-0efe00f7379e'", who = 'Xing Brew')

# confirmed in cases below that no changes are needed to hh_hamlet_code or hh_hamlet, only hh_id, permid, pid
implement(id = 'repeat_hh_id_358d32a0-480d-4a2a-b507-5244f92a2ecf,8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb', query = "UPDATE clean_minicensus_main SET hh_id='DEU-216' WHERE instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'; UPDATE clean_minicensus_people SET pid='DEU-216-001', permid='DEU-216-001' WHERE num='1' and instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'; UPDATE clean_minicensus_people SET pid='DEU-216-002', permid='DEU-216-002' WHERE num='2' and instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'; UPDATE clean_minicensus_people SET pid='DEU-216-003', permid='DEU-216-003' WHERE num='3' and instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'; UPDATE clean_minicensus_people SET pid='DEU-216-004', permid='DEU-216-004' WHERE num='4' and instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'; UPDATE clean_minicensus_people SET pid='DEU-216-005', permid='DEU-216-005' WHERE num='5' and instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'; UPDATE clean_minicensus_people SET pid='DEU-216-006', permid='DEU-216-006' WHERE num='6' and instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'", who =  'Xing Brew')
implement(id = 'repeat_hh_id_03d42b97-29e0-4397-8e7b-a2f43cfcf2c4,a89d7c1b-5d7d-4d8d-a61c-7be20e58d6a9', query = "UPDATE clean_minicensus_main SET hh_id='DEA-227' WHERE instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-001', permid='DEA-227-001' WHERE num='1' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-002', permid='DEA-227-002' WHERE num='2' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-003', permid='DEA-227-003' WHERE num='3' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-004', permid='DEA-227-004' WHERE num='4' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-005', permid='DEA-227-005' WHERE num='5' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-006', permid='DEA-227-006' WHERE num='6' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-007', permid='DEA-227-007' WHERE num='7' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-008', permid='DEA-227-008' WHERE num='8' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'; UPDATE clean_minicensus_people SET pid='DEA-227-009', permid='DEA-227-009' WHERE num='9' and instance_id='03d42b97-29e0-4397-8e7b-a2f43cfcf2c4'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_05f3c2e6-f01f-4dd5-9f84-e89f7c51e4c0,76a749f5-24f7-4fd5-b93d-69924d3218b6', query = "UPDATE clean_minicensus_main SET hh_id='DEJ-091' WHERE instance_id='76a749f5-24f7-4fd5-b93d-69924d3218b6'; UPDATE clean_minicensus_people SET pid='DEJ-091-001', permid='DEJ-091-001' WHERE num='1' and instance_id='76a749f5-24f7-4fd5-b93d-69924d3218b6'; UPDATE clean_minicensus_people SET pid='DEJ-091-002', permid='DEJ-091-002' WHERE num='2' and instance_id='76a749f5-24f7-4fd5-b93d-69924d3218b6'; UPDATE clean_minicensus_people SET pid='DEJ-091-003', permid='DEJ-091-003' WHERE num='3' and instance_id='76a749f5-24f7-4fd5-b93d-69924d3218b6'; UPDATE clean_minicensus_people SET pid='DEJ-091-004', permid='DEJ-091-004' WHERE num='4' and instance_id='76a749f5-24f7-4fd5-b93d-69924d3218b6'; UPDATE clean_minicensus_people SET pid='DEJ-091-005', permid='DEJ-091-005' WHERE num='5' and instance_id='76a749f5-24f7-4fd5-b93d-69924d3218b6'; UPDATE clean_minicensus_people SET pid='DEJ-091-006', permid='DEJ-091-006' WHERE num='6' and instance_id='76a749f5-24f7-4fd5-b93d-69924d3218b6'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_8871e6f5-e7a1-451a-aa12-9c77ec4719d0,a7ae4b37-3b56-44d9-be3b-f63ee89c3b1b', query = "UPDATE clean_minicensus_main SET hh_id='DEJ-129' WHERE instance_id='8871e6f5-e7a1-451a-aa12-9c77ec4719d0'; UPDATE clean_minicensus_people SET pid='DEJ-129-001', permid='DEJ-129-001' WHERE num='1' and instance_id='8871e6f5-e7a1-451a-aa12-9c77ec4719d0'; UPDATE clean_minicensus_people SET pid='DEJ-129-002', permid='DEJ-129-002' WHERE num='2' and instance_id='8871e6f5-e7a1-451a-aa12-9c77ec4719d0'; UPDATE clean_minicensus_people SET pid='DEJ-129-003', permid='DEJ-129-003' WHERE num='3' and instance_id='8871e6f5-e7a1-451a-aa12-9c77ec4719d0'; UPDATE clean_minicensus_people SET pid='DEJ-129-004', permid='DEJ-129-004' WHERE num='4' and instance_id='8871e6f5-e7a1-451a-aa12-9c77ec4719d0'; UPDATE clean_minicensus_people SET pid='DEJ-129-005', permid='DEJ-129-005' WHERE num='5' and instance_id='8871e6f5-e7a1-451a-aa12-9c77ec4719d0'; UPDATE clean_minicensus_people SET pid='DEJ-129-006', permid='DEJ-129-006' WHERE num='6' and instance_id='8871e6f5-e7a1-451a-aa12-9c77ec4719d0'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_4bc679fa-fb6e-46c9-9283-ac6619757559,91afe35f-0f74-4966-9dfd-3693059b2c83', query = "UPDATE clean_minicensus_main SET hh_id='DEO-221' WHERE instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-001', permid='DEO-221-001' WHERE num='1' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-002', permid='DEO-221-002' WHERE num='2' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-003', permid='DEO-221-003' WHERE num='3' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-004', permid='DEO-221-004' WHERE num='4' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-005', permid='DEO-221-005' WHERE num='5' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-006', permid='DEO-221-006' WHERE num='6' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-007', permid='DEO-221-007' WHERE num='7' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-008', permid='DEO-221-008' WHERE num='8' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'; UPDATE clean_minicensus_people SET pid='DEO-221-009', permid='DEO-221-009' WHERE num='9' and instance_id='4bc679fa-fb6e-46c9-9283-ac6619757559'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_ea3a5fae-9db2-43e5-bc5f-1ed05708e70c,897c9ff1-5ea3-4d14-8e0a-71fd3468b6b6', query = "UPDATE clean_minicensus_main SET hh_id='DEO-195' WHERE instance_id='897c9ff1-5ea3-4d14-8e0a-71fd3468b6b6'; UPDATE clean_minicensus_people SET pid='DEO-195-001', permid='DEO-195-001' WHERE num='1' and instance_id='897c9ff1-5ea3-4d14-8e0a-71fd3468b6b6'; UPDATE clean_minicensus_people SET pid='DEO-195-002', permid='DEO-195-002' WHERE num='2' and instance_id='897c9ff1-5ea3-4d14-8e0a-71fd3468b6b6'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_9490500b-1500-4964-b56a-2ba529e60d00,c567b513-b6aa-4fec-94a3-2728f0f035f9', query = "UPDATE clean_minicensus_main SET hh_id='DEO-305' WHERE instance_id='c567b513-b6aa-4fec-94a3-2728f0f035f9'; UPDATE clean_minicensus_people SET pid='DEO-305-001', permid='DEO-305-001' WHERE num='1' and instance_id='c567b513-b6aa-4fec-94a3-2728f0f035f9'; UPDATE clean_minicensus_people SET pid='DEO-305-002', permid='DEO-305-002' WHERE num='2' and instance_id='c567b513-b6aa-4fec-94a3-2728f0f035f9'; UPDATE clean_minicensus_people SET pid='DEO-305-003', permid='DEO-305-003' WHERE num='3' and instance_id='c567b513-b6aa-4fec-94a3-2728f0f035f9'; UPDATE clean_minicensus_people SET pid='DEO-305-004', permid='DEO-305-004' WHERE num='4' and instance_id='c567b513-b6aa-4fec-94a3-2728f0f035f9'; UPDATE clean_minicensus_people SET pid='DEO-305-005', permid='DEO-305-005' WHERE num='5' and instance_id='c567b513-b6aa-4fec-94a3-2728f0f035f9'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_9ef87b46-3589-4ead-adfe-ac800966ce6b,6085c7bb-9a8e-4935-b26f-9b2e31e021f1', query = "UPDATE clean_minicensus_main SET hh_id='DEO-048' WHERE instance_id='9ef87b46-3589-4ead-adfe-ac800966ce6b'; UPDATE clean_minicensus_people SET pid='DEO-048-001', permid='DEO-048-001' WHERE num='1' and instance_id='9ef87b46-3589-4ead-adfe-ac800966ce6b'; UPDATE clean_minicensus_people SET pid='DEO-048-002', permid='DEO-048-002' WHERE num='2' and instance_id='9ef87b46-3589-4ead-adfe-ac800966ce6b'; UPDATE clean_minicensus_people SET pid='DEO-048-003', permid='DEO-048-003' WHERE num='3' and instance_id='9ef87b46-3589-4ead-adfe-ac800966ce6b'; UPDATE clean_minicensus_people SET pid='DEO-048-004', permid='DEO-048-004' WHERE num='4' and instance_id='9ef87b46-3589-4ead-adfe-ac800966ce6b'; UPDATE clean_minicensus_people SET pid='DEO-048-005', permid='DEO-048-005' WHERE num='5' and instance_id='9ef87b46-3589-4ead-adfe-ac800966ce6b'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_4d1f52b3-52b7-4d63-8972-e11f0b401703,c8a3c0e5-727d-4c4d-a7fe-34221e7dd52e', query = "UPDATE clean_minicensus_main SET hh_id='DEO-102' WHERE instance_id='c8a3c0e5-727d-4c4d-a7fe-34221e7dd52e'; UPDATE clean_minicensus_people SET pid='DEO-102-001', permid='DEO-102-001' WHERE num='1' and instance_id='c8a3c0e5-727d-4c4d-a7fe-34221e7dd52e'; UPDATE clean_minicensus_people SET pid='DEO-102-002', permid='DEO-102-002' WHERE num='2' and instance_id='c8a3c0e5-727d-4c4d-a7fe-34221e7dd52e'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_0bcd5949-6657-4c7f-a5f2-b2b56dfb4cbe,b5da243a-dd40-47d5-be59-75bd08a7e4dc', query = "UPDATE clean_minicensus_main SET hh_id='DEU-138' WHERE instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-001', permid='DEU-138-001' WHERE num='1' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-002', permid='DEU-138-002' WHERE num='2' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-003', permid='DEU-138-003' WHERE num='3' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-004', permid='DEU-138-004' WHERE num='4' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-005', permid='DEU-138-005' WHERE num='5' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-006', permid='DEU-138-006' WHERE num='6' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-007', permid='DEU-138-007' WHERE num='7' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-008', permid='DEU-138-008' WHERE num='8' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-009', permid='DEU-138-009' WHERE num='9' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'; UPDATE clean_minicensus_people SET pid='DEU-138-010', permid='DEU-138-010' WHERE num='10' and instance_id='b5da243a-dd40-47d5-be59-75bd08a7e4dc'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_42a0ad4d-d7a6-40f1-b39d-37ac60647d32,e43faf00-ac5d-4511-9cba-205e2bd00ae1', query = "UPDATE clean_minicensus_main SET hh_id='DEO-168' WHERE instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'; UPDATE clean_minicensus_people SET pid='DEO-168-001', permid='DEO-168-001' WHERE num='1' and instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'; UPDATE clean_minicensus_people SET pid='DEO-168-002', permid='DEO-168-002' WHERE num='2' and instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'; UPDATE clean_minicensus_people SET pid='DEO-168-003', permid='DEO-168-003' WHERE num='3' and instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'; UPDATE clean_minicensus_people SET pid='DEO-168-004', permid='DEO-168-004' WHERE num='4' and instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'; UPDATE clean_minicensus_people SET pid='DEO-168-005', permid='DEO-168-005' WHERE num='5' and instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'; UPDATE clean_minicensus_people SET pid='DEO-168-006', permid='DEO-168-006' WHERE num='6' and instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'; UPDATE clean_minicensus_people SET pid='DEO-168-007', permid='DEO-168-007' WHERE num='7' and instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'; UPDATE clean_minicensus_people SET pid='DEO-168-008', permid='DEO-168-008' WHERE num='8' and instance_id='42a0ad4d-d7a6-40f1-b39d-37ac60647d32'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_8df6c657-ce24-4ea4-9a8c-aa38a38cf1d7,b996b7ef-2190-4773-a41a-2aca48c2485d', query = "UPDATE clean_minicensus_main SET hh_id='DEU-283' WHERE instance_id='8df6c657-ce24-4ea4-9a8c-aa38a38cf1d7'; UPDATE clean_minicensus_people SET pid='DEU-283-001', permid='DEU-283-001' WHERE num='1' and instance_id='8df6c657-ce24-4ea4-9a8c-aa38a38cf1d7'; UPDATE clean_minicensus_people SET pid='DEU-283-002', permid='DEU-283-002' WHERE num='2' and instance_id='8df6c657-ce24-4ea4-9a8c-aa38a38cf1d7'; UPDATE clean_minicensus_people SET pid='DEU-283-003', permid='DEU-283-003' WHERE num='3' and instance_id='8df6c657-ce24-4ea4-9a8c-aa38a38cf1d7'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_2d5f3098-c625-49c4-8a75-d336e45b2639,be2a9fc1-249b-4951-8e84-7224a37e2570', query = "UPDATE clean_minicensus_main SET hh_id='DEX-105' WHERE instance_id='2d5f3098-c625-49c4-8a75-d336e45b2639'; UPDATE clean_minicensus_people SET pid='DEX-105-001', permid='DEX-105-001' WHERE num='1' and instance_id='2d5f3098-c625-49c4-8a75-d336e45b2639'; UPDATE clean_minicensus_people SET pid='DEX-105-002', permid='DEX-105-002' WHERE num='2' and instance_id='2d5f3098-c625-49c4-8a75-d336e45b2639'; UPDATE clean_minicensus_people SET pid='DEX-105-003', permid='DEX-105-003' WHERE num='3' and instance_id='2d5f3098-c625-49c4-8a75-d336e45b2639'; UPDATE clean_minicensus_people SET pid='DEX-105-004', permid='DEX-105-004' WHERE num='4' and instance_id='2d5f3098-c625-49c4-8a75-d336e45b2639'; UPDATE clean_minicensus_people SET pid='DEX-105-005', permid='DEX-105-005' WHERE num='5' and instance_id='2d5f3098-c625-49c4-8a75-d336e45b2639'; UPDATE clean_minicensus_people SET pid='DEX-105-006', permid='DEX-105-006' WHERE num='6' and instance_id='2d5f3098-c625-49c4-8a75-d336e45b2639'; UPDATE clean_minicensus_people SET pid='DEX-105-007', permid='DEX-105-007' WHERE num='7' and instance_id='2d5f3098-c625-49c4-8a75-d336e45b2639'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99,80034941-284b-47f4-9559-7a098b81608b', query = "UPDATE clean_minicensus_main SET hh_id='FFF-134' WHERE instance_id='1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99'; UPDATE clean_minicensus_people SET pid='FFF-134-001', permid='FFF-134-001' WHERE num='1' and instance_id='1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99'; UPDATE clean_minicensus_people SET pid='FFF-134-002', permid='FFF-134-002' WHERE num='2' and instance_id='1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99'; UPDATE clean_minicensus_people SET pid='FFF-134-003', permid='FFF-134-003' WHERE num='3' and instance_id='1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99'; UPDATE clean_minicensus_people SET pid='FFF-134-004', permid='FFF-134-004' WHERE num='4' and instance_id='1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99'; UPDATE clean_minicensus_people SET pid='FFF-134-005', permid='FFF-134-005' WHERE num='5' and instance_id='1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99'; UPDATE clean_minicensus_people SET pid='FFF-134-006', permid='FFF-134-006' WHERE num='6' and instance_id='1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99'; UPDATE clean_minicensus_people SET pid='FFF-134-007', permid='FFF-134-007' WHERE num='7' and instance_id='1e52cee8-93a6-4e51-8e2d-e4bfa18f9d99'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_1a77ac52-ccc3-445f-8ae6-1426f1f2a632,6ffa7378-b1fe-4f39-9a96-9f14fd97704e', query = "UPDATE clean_minicensus_main SET hh_id='MIF-084' WHERE instance_id='6ffa7378-b1fe-4f39-9a96-9f14fd97704e'; UPDATE clean_minicensus_people SET pid='MIF-084-001', permid='MIF-084-001' WHERE num='1' and instance_id='6ffa7378-b1fe-4f39-9a96-9f14fd97704e'; UPDATE clean_minicensus_people SET pid='MIF-084-002', permid='MIF-084-002' WHERE num='2' and instance_id='6ffa7378-b1fe-4f39-9a96-9f14fd97704e'; UPDATE clean_minicensus_people SET pid='MIF-084-003', permid='MIF-084-003' WHERE num='3' and instance_id='6ffa7378-b1fe-4f39-9a96-9f14fd97704e'; UPDATE clean_minicensus_people SET pid='MIF-084-004', permid='MIF-084-004' WHERE num='4' and instance_id='6ffa7378-b1fe-4f39-9a96-9f14fd97704e'; UPDATE clean_minicensus_people SET pid='MIF-084-005', permid='MIF-084-005' WHERE num='5' and instance_id='6ffa7378-b1fe-4f39-9a96-9f14fd97704e'; UPDATE clean_minicensus_people SET pid='MIF-084-006', permid='MIF-084-006' WHERE num='6' and instance_id='6ffa7378-b1fe-4f39-9a96-9f14fd97704e'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_f3f7fd05-511c-450c-93ab-659528e45381,1e0e5093-ac9e-4f24-aedb-5c1fc18b9439', query = "UPDATE clean_minicensus_main SET hh_id='MIF-152' WHERE instance_id='1e0e5093-ac9e-4f24-aedb-5c1fc18b9439'; UPDATE clean_minicensus_people SET pid='MIF-152-001', permid='MIF-152-001' WHERE num='1' and instance_id='1e0e5093-ac9e-4f24-aedb-5c1fc18b9439'; UPDATE clean_minicensus_people SET pid='MIF-152-002', permid='MIF-152-002' WHERE num='2' and instance_id='1e0e5093-ac9e-4f24-aedb-5c1fc18b9439'; UPDATE clean_minicensus_people SET pid='MIF-152-003', permid='MIF-152-003' WHERE num='3' and instance_id='1e0e5093-ac9e-4f24-aedb-5c1fc18b9439'; UPDATE clean_minicensus_people SET pid='MIF-152-004', permid='MIF-152-004' WHERE num='4' and instance_id='1e0e5093-ac9e-4f24-aedb-5c1fc18b9439'; UPDATE clean_minicensus_people SET pid='MIF-152-005', permid='MIF-152-005' WHERE num='5' and instance_id='1e0e5093-ac9e-4f24-aedb-5c1fc18b9439'; UPDATE clean_minicensus_people SET pid='MIF-152-006', permid='MIF-152-006' WHERE num='6' and instance_id='1e0e5093-ac9e-4f24-aedb-5c1fc18b9439'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_4aea9bac-6360-4da9-848b-4916d41f8547,90406959-33f4-4b46-930f-dbe010c9c8d2,c42c2923-ed12-47ac-aa65-9291ea353192,cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8,d6332d21-80f8-483a-83ce-716d1228ed32', query = "UPDATE clean_minicensus_main SET hh_id='JSA-089' WHERE instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_people SET pid='JSA-089-001', permid='JSA-089-001' WHERE num='1' and instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_people SET pid='JSA-089-002', permid='JSA-089-002' WHERE num='2' and instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_people SET pid='JSA-089-003', permid='JSA-089-003' WHERE num='3' and instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_people SET pid='JSA-089-004', permid='JSA-089-004' WHERE num='4' and instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_people SET pid='JSA-089-005', permid='JSA-089-005' WHERE num='5' and instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_people SET pid='JSA-089-006', permid='JSA-089-006' WHERE num='6' and instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_people SET pid='JSA-089-007', permid='JSA-089-007' WHERE num='7' and instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_people SET pid='JSA-089-008', permid='JSA-089-008' WHERE num='8' and instance_id='d6332d21-80f8-483a-83ce-716d1228ed32'; UPDATE clean_minicensus_main SET hh_id='JSA-089' WHERE instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_people SET pid='JSA-090-001', permid='JSA-090-001' WHERE num='1' and instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_people SET pid='JSA-090-002', permid='JSA-090-002' WHERE num='2' and instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_people SET pid='JSA-090-003', permid='JSA-090-003' WHERE num='3' and instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_people SET pid='JSA-090-004', permid='JSA-090-004' WHERE num='4' and instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_people SET pid='JSA-090-005', permid='JSA-090-005' WHERE num='5' and instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_people SET pid='JSA-090-006', permid='JSA-090-006' WHERE num='6' and instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_people SET pid='JSA-090-007', permid='JSA-090-007' WHERE num='7' and instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_people SET pid='JSA-090-008', permid='JSA-090-008' WHERE num='8' and instance_id='cbb02406-d8f2-4ced-b59b-ae3dcf7d9cc8'; UPDATE clean_minicensus_main SET hh_id='JSA-007' WHERE instance_id='90406959-33f4-4b46-930f-dbe010c9c8d2'; UPDATE clean_minicensus_people SET pid='JSA-007-001', permid='JSA-007-001' WHERE num='1' and instance_id='90406959-33f4-4b46-930f-dbe010c9c8d2'; UPDATE clean_minicensus_people SET pid='JSA-007-002', permid='JSA-007-002' WHERE num='2' and instance_id='90406959-33f4-4b46-930f-dbe010c9c8d2'; UPDATE clean_minicensus_people SET pid='JSA-007-003', permid='JSA-007-003' WHERE num='3' and instance_id='90406959-33f4-4b46-930f-dbe010c9c8d2'; UPDATE clean_minicensus_people SET pid='JSA-007-004', permid='JSA-007-004' WHERE num='4' and instance_id='90406959-33f4-4b46-930f-dbe010c9c8d2'; UPDATE clean_minicensus_people SET pid='JSA-007-005', permid='JSA-007-005' WHERE num='5' and instance_id='90406959-33f4-4b46-930f-dbe010c9c8d2'; UPDATE clean_minicensus_main SET hh_id='JSA-053' WHERE instance_id='4aea9bac-6360-4da9-848b-4916d41f8547'; UPDATE clean_minicensus_people SET pid='JSA-053-001', permid='JSA-053-001' WHERE num='1' and instance_id='4aea9bac-6360-4da9-848b-4916d41f8547'; UPDATE clean_minicensus_people SET pid='JSA-053-002', permid='JSA-053-002' WHERE num='2' and instance_id='4aea9bac-6360-4da9-848b-4916d41f8547'; UPDATE clean_minicensus_people SET pid='JSA-053-003', permid='JSA-053-003' WHERE num='3' and instance_id='4aea9bac-6360-4da9-848b-4916d41f8547'; UPDATE clean_minicensus_people SET pid='JSA-053-004', permid='JSA-053-004' WHERE num='4' and instance_id='4aea9bac-6360-4da9-848b-4916d41f8547'; UPDATE clean_minicensus_people SET pid='JSA-053-005', permid='JSA-053-005' WHERE num='5' and instance_id='4aea9bac-6360-4da9-848b-4916d41f8547'; UPDATE clean_minicensus_main SET hh_id='JSA-054' WHERE instance_id='c42c2923-ed12-47ac-aa65-9291ea353192'; UPDATE clean_minicensus_people SET pid='JSA-054-001', permid='JSA-054-001' WHERE num='1' and instance_id='c42c2923-ed12-47ac-aa65-9291ea353192'; UPDATE clean_minicensus_people SET pid='JSA-054-002', permid='JSA-054-002' WHERE num='2' and instance_id='c42c2923-ed12-47ac-aa65-9291ea353192'; UPDATE clean_minicensus_people SET pid='JSA-054-003', permid='JSA-054-003' WHERE num='3' and instance_id='c42c2923-ed12-47ac-aa65-9291ea353192'; UPDATE clean_minicensus_people SET pid='JSA-054-004', permid='JSA-054-004' WHERE num='4' and instance_id='c42c2923-ed12-47ac-aa65-9291ea353192'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_0d09707a-51be-4e91-a5e8-5534fb7bd007,7f97b88a-4090-4c81-aab7-b26fa51d5e99,fe970bb0-521c-4a82-b7d7-b8ef282b1bbb', query = "UPDATE clean_minicensus_main SET hh_id='MUR-043' WHERE instance_id='7f97b88a-4090-4c81-aab7-b26fa51d5e99'; UPDATE clean_minicensus_people SET pid='MUR-043-001', permid='MUR-043-001' WHERE num='1' and instance_id='7f97b88a-4090-4c81-aab7-b26fa51d5e99'; UPDATE clean_minicensus_people SET pid='MUR-043-002', permid='MUR-043-002' WHERE num='2' and instance_id='7f97b88a-4090-4c81-aab7-b26fa51d5e99'; UPDATE clean_minicensus_people SET pid='MUR-043-003', permid='MUR-043-003' WHERE num='3' and instance_id='7f97b88a-4090-4c81-aab7-b26fa51d5e99'; UPDATE clean_minicensus_people SET pid='MUR-043-004', permid='MUR-043-004' WHERE num='4' and instance_id='7f97b88a-4090-4c81-aab7-b26fa51d5e99'; UPDATE clean_minicensus_people SET pid='MUR-042-001', permid='MUR-042-001' WHERE num='1' and instance_id='0d09707a-51be-4e91-a5e8-5534fb7bd007'; UPDATE clean_minicensus_people SET pid='MUR-042-002', permid='MUR-042-002' WHERE num='2' and instance_id='0d09707a-51be-4e91-a5e8-5534fb7bd007'; UPDATE clean_minicensus_people SET pid='MUR-042-003', permid='MUR-042-003' WHERE num='3' and instance_id='0d09707a-51be-4e91-a5e8-5534fb7bd007'; UPDATE clean_minicensus_people SET pid='MUR-042-004', permid='MUR-042-004' WHERE num='4' and instance_id='0d09707a-51be-4e91-a5e8-5534fb7bd007'; UPDATE clean_minicensus_people SET pid='MUR-042-005', permid='MUR-042-005' WHERE num='5' and instance_id='0d09707a-51be-4e91-a5e8-5534fb7bd007'; UPDATE clean_minicensus_main SET hh_id='MUR-041' WHERE instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-001', permid='MUR-041-001' WHERE num='1' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-002', permid='MUR-041-002' WHERE num='2' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-003', permid='MUR-041-003' WHERE num='3' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-004', permid='MUR-041-004' WHERE num='4' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-005', permid='MUR-041-005' WHERE num='5' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-006', permid='MUR-041-006' WHERE num='6' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-007', permid='MUR-041-007' WHERE num='7' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-008', permid='MUR-041-008' WHERE num='8' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'; UPDATE clean_minicensus_people SET pid='MUR-041-009', permid='MUR-041-009' WHERE num='9' and instance_id='fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'", who = 'Xing Brew')
# Manual email-requested changes, Imani, Dec 15 2020
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='87' WHERE instance_id ='d96a675f-0d00-4775-b9b7-404aed164e84'", who = 'Joe Brew')
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='6' WHERE instance_id ='89e583e9-8097-42f9-8eef-5f8726e02e3d'", who = 'Joe Brew')
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='6' WHERE instance_id ='3f44a2be-a069-4f28-ba54-2c535b604599'", who = 'Joe Brew')
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='30' WHERE instance_id ='37b1408b-c255-4dda-94bd-61d57bd52b3b'", who = 'Joe Brew')
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='30' WHERE instance_id ='4beae8b8-00c4-43b8-b1ae-0028843e17b5'", who = 'Joe Brew')
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='59' WHERE instance_id ='ff5e9d57-3122-4c80-a400-881791b770bc'", who = 'Joe Brew')
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='59' WHERE instance_id ='ba57e8d9-d524-4b61-90ae-edd1b3a9bc51'", who = 'Joe Brew')
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='87' WHERE instance_id ='170dc903-4bbb-474b-a775-315ee18de501'", who = 'Joe Brew')
implement(id = None, query = "UPDATE clean_minicensus_main SET wid='2' WHERE instance_id ='82d018ff-0059-4bef-8226-dc048a41ee59'", who = 'Joe Brew')
# Manual email-requested changes, Imani, Dec 11 2020
# Refusals
implement(id = None, query = "DELETE FROM clean_refusals WHERE hh_id ='MGO-106'", who = 'Joe Brew')
implement(id = None, query = "DELETE FROM clean_refusals WHERE hh_id ='MOL-003'", who = 'Joe Brew')
implement(id = None, query = "DELETE FROM clean_refusals WHERE hh_id ='NNE-076'", who = 'Joe Brew')
implement(id = None, query = "DELETE FROM clean_refusals WHERE hh_id ='MWY-083'", who = 'Joe Brew')
implement(id = None, query = "DELETE FROM clean_refusals WHERE hh_id ='MWY-098'", who = 'Joe Brew')
implement(id = None, query = "DELETE FROM clean_refusals WHERE hh_id ='MWY-130'", who = 'Joe Brew')
# Deaths
iid = "'1774a143-6a01-434a-8cb6-69259e55f9af'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'052e652d-741c-4b21-b6df-67101e52e090'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'b907bf59-92e5-4c88-8829-83bf8326d066'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'44c1aa3d-2cd4-4cb8-8970-fe4089651473'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'8a6dd323-7834-4bb5-a0f8-4f9f6e796e18'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'1826c57f-2153-48a6-8e0c-d39b6b411d44'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'f6f4eb29-a3bc-4b19-99d4-509d40a7da9a'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'5052e444-2e37-4286-b075-d20bf21c4e03'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'65b0ff6c-e9ad-4804-8841-51a9dc5cce11'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'112adacf-2739-47fe-8855-3aa4ea47690f'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'ddb6e1c8-b84a-44ad-8169-0e33e728ccbf'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'8dcff214-34ed-423e-aab3-7f849d9f6c2b'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'0767af3b-681e-4c96-b280-a3f6ca9b4312'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'13d417af-7d34-48d9-96fd-be69daff70da'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'1ce5ce7f-ebc7-4556-9e9f-35899e199c8c'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'093a8106-9e2a-4bcb-92b6-62c35c0c519d'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'8dfc448e-c66a-4232-85c7-8b4bee30bffe'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")
iid = "'2774e59a-76cd-46cf-a202-a1ff27aff836'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year = 'No' where instance_id = " + iid + "; DELETE FROM minicensus_repeat_death_info WHERE instance_id = " + iid + ";")


# Removing refusals unless VA Fieldworker, as requested by Eldo - Dec 17
implement(id=None, query="DELETE FROM clean_refusals WHERE instance_id='2d16e296-5aef-4f52-80f2-afe15134cd31'", who='Xing Brew')
implement(id=None, query="DELETE FROM clean_refusals WHERE instance_id='ece28d13-4be1-475d-b5a2-dee069d34453'", who='Xing Brew')
implement(id=None, query="DELETE FROM clean_refusals WHERE instance_id='40413108-afc3-42dd-b4aa-58c6561c7872'", who='Xing Brew')
implement(id=None, query="DELETE FROM clean_refusals WHERE instance_id='b5a32ef2-ffda-4c00-893f-4350ce00376a'", who='Xing Brew')
implement(id=None, query="DELETE FROM clean_refusals WHERE instance_id='6dfefd8b-1c38-4230-94fb-e89ce0262f08'", who='Xing Brew')
implement(id=None, query="DELETE FROM clean_refusals WHERE instance_id='6dfefd8b-1c38-4230-94fb-e89ce0262f08'", who='Xing Brew')

# Xing Dec 22 Fixes

iid = "'1f547eea-9781-48d3-93c4-9ab8a5a223b5'"
implement(id = 'repeat_hh_id_81f8c2c2-deac-472a-9076-7f46deedb7cf,1f547eea-9781-48d3-93c4-9ab8a5a223b5', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'2fa8fd58-f946-44f6-803f-2f10e5c7fa58'"
implement(id = 'repeat_hh_id_2fa8fd58-f946-44f6-803f-2f10e5c7fa58,4a17ad7d-26e9-4477-bf0d-d52cef18c93f', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'33f00745-79ef-4c03-b960-9ad87fe74f35'"
implement(id = 'repeat_hh_id_e406fdd2-8b40-4ec6-878b-d0497b670d0c,33f00745-79ef-4c03-b960-9ad87fe74f35', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'4a093159-3976-4918-bd89-343cb2c242b9'"
implement(id = 'repeat_hh_id_837c4e45-78b9-457a-bd5b-26419508633a,4a093159-3976-4918-bd89-343cb2c242b9', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'be52f759-b06a-431a-a999-81494e7ba9bc'"
implement(id = 'repeat_hh_id_be52f759-b06a-431a-a999-81494e7ba9bc,93298419-2132-44c4-9005-fd5f8f7de956', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'16daa3c8-a319-4470-9096-b9abcd66d55d'"
implement(id = 'repeat_hh_id_eaeb3490-57b9-4c4a-ad42-c6a56e0cc288,16daa3c8-a319-4470-9096-b9abcd66d55d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'2142a84c-6a40-4575-a9fb-f6a7ba96e9dc'"
implement(id = 'repeat_hh_id_2142a84c-6a40-4575-a9fb-f6a7ba96e9dc,f8269063-a29b-445d-9ae0-7423984cb2ae', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'26447f9a-9e41-40df-89bd-2e5b60f04a7c'"
implement(id = 'repeat_hh_id_fb9b10e7-b834-4427-a67b-1f1952cdc09b,26447f9a-9e41-40df-89bd-2e5b60f04a7c', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'3ecd60b0-09ad-4868-b7af-83d85443efa5'"
implement(id = 'repeat_hh_id_3ecd60b0-09ad-4868-b7af-83d85443efa5,c6ad72e3-a3ab-451e-8fff-64e5b1845893', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'3ede809d-2f53-49ca-8991-abffd1c588e7'"
implement(id = 'repeat_hh_id_3ede809d-2f53-49ca-8991-abffd1c588e7,6ce10dd8-fc1f-49cd-936b-ec1fc3ead8ef', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'3f297aeb-103e-4f11-94c1-9dc1d1cc91bd'"
implement(id = 'repeat_hh_id_aeba029e-59ce-488a-977f-974a240de63f,3f297aeb-103e-4f11-94c1-9dc1d1cc91bd', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'415d50c5-501e-4de9-bf7f-0d8f47b04b8a'"
implement(id = 'repeat_hh_id_6ee1de0b-ecde-4cb3-8280-fc6b7f5aa366,415d50c5-501e-4de9-bf7f-0d8f47b04b8a', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'490dbd71-db7c-43bf-81cb-2b012d2c5818'"
implement(id = 'repeat_hh_id_490dbd71-db7c-43bf-81cb-2b012d2c5818,89e555f2-8b29-4956-b0ff-4a05666e024f', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'4cb94088-f87c-4839-b972-45659392dee3'"
implement(id = 'repeat_hh_id_68b8ccfc-b4d4-45d6-9239-efdea982c3dc,4cb94088-f87c-4839-b972-45659392dee3', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'50599e7f-b164-4493-9dfd-f0598ba3ccc6'"
implement(id = 'repeat_hh_id_50599e7f-b164-4493-9dfd-f0598ba3ccc6,d0fcc220-83b1-4a1d-8b82-9a5f8375f78e', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'5c97c20d-b8eb-4b91-ac6b-8758ad61293a'"
implement(id = 'repeat_hh_id_c04c4011-f97e-400e-b4d5-47587a72da51,5c97c20d-b8eb-4b91-ac6b-8758ad61293a', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'620fa39e-e516-49e9-a579-3dbad0db0974'"
implement(id = 'repeat_hh_id_620fa39e-e516-49e9-a579-3dbad0db0974,d380115a-29dd-434e-a1cc-6f16d2555d83', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'8a35f2f8-dd81-4acd-aa80-d22506628c80'"
implement(id = 'repeat_hh_id_cc44726d-bee7-4efc-8c44-b869fca5c0c0,8a35f2f8-dd81-4acd-aa80-d22506628c80', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'a707435f-45d1-4a9a-8533-384b013f3ec9'"
implement(id = 'repeat_hh_id_5f6d1a0f-1e70-47a1-b00d-f30a3a70466a,a707435f-45d1-4a9a-8533-384b013f3ec9', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'a7266d15-f91e-45c2-86c2-efb3f5b16d26'"
implement(id = 'repeat_hh_id_05ca0f7d-3bf0-48ba-a64b-24238d3862de,a7266d15-f91e-45c2-86c2-efb3f5b16d26', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'adae21bd-4f6c-4535-97d6-0ee7705ce8b3'"
implement(id = 'repeat_hh_id_82d82f41-fab4-4e42-a3be-5ae5186d2393,adae21bd-4f6c-4535-97d6-0ee7705ce8b3', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'b9e5453b-cdb0-4fcd-ae9c-5a1006bfd2a5'"
implement(id = 'repeat_hh_id_b9e5453b-cdb0-4fcd-ae9c-5a1006bfd2a5,d067b8ed-191d-4c7b-94ae-a8f6d2b0f6ac', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'bb792dec-0bd4-4677-89d6-02b001083101'"
implement(id = 'repeat_hh_id_50e264f8-5208-42a1-a3e1-3bf9b89ea258,bb792dec-0bd4-4677-89d6-02b001083101', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'cf99bbf5-616b-4c77-ae53-733228dff3ba'"
implement(id = 'repeat_hh_id_41e41f4a-e911-4289-bc2d-72eae2630db8,cf99bbf5-616b-4c77-ae53-733228dff3ba', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'d51508cf-202c-4461-9ec3-57116150288d'"
implement(id = 'repeat_hh_id_17567fa6-42ca-4f10-8586-50c53946ffbb,d51508cf-202c-4461-9ec3-57116150288d', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'eeeddbec-61e0-43d8-8838-9eb6ebcd42e5'"
implement(id = 'repeat_hh_id_42036ba8-fb04-44e3-9611-1bd042e1b0c5,eeeddbec-61e0-43d8-8838-9eb6ebcd42e5', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'5a025971-0eeb-4dcd-8f74-8b7e5908155a'"
implement(id = 'repeat_hh_id_5a025971-0eeb-4dcd-8f74-8b7e5908155a,e8a8097a-2482-4d39-aacb-9dc0875ed0bc', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')
iid = "'9b110539-1a38-4b6f-90db-54e142828d28'"
implement(id = 'repeat_hh_id_3e04fa31-df8d-4f2d-87c0-df8b44ef3f41,9b110539-1a38-4b6f-90db-54e142828d28', query = "DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'d0900e50-2121-473c-8b81-5feaa46b340b'"
implement(id = 'repeat_hh_id_enumerations_a3df1b53-1ec5-4a5c-9e9a-6d4e814b1c26,d0900e50-2121-473c-8b81-5feaa46b340b', query = "DELETE FROM clean_enumerations WHERE instance_id=" + iid + ";", who = 'Xing Brew')

implement(id = 'strange_wid_enumerations_aff99992-154a-4d2b-bdef-c5a9cd62ceba', query = "UPDATE clean_enumerations SET wid='424', wid_manual='424' WHERE instance_id='aff99992-154a-4d2b-bdef-c5a9cd62ceba'", who = 'Xing Brew')
implement(id = 'strange_wid_enumerations_50f596d8-32e5-4a48-9fdd-3dc972b211cd', query = "UPDATE clean_enumerations SET wid='428', wid_manual='428' WHERE instance_id='50f596d8-32e5-4a48-9fdd-3dc972b211cd'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_0ce36453-53a5-44e2-af3a-e9f38e4b98b9,4f15176c-7d4f-449a-a5a4-581afa4f0028', query = "UPDATE clean_minicensus_main SET hh_id='XHC-049', hh_hamlet='Chimindwe', hh_hamlet_code='XHC' WHERE instance_id='15b7e943-fcdc-4743-a24d-99897dc4753d';UPDATE clean_minicensus_people SET pid = 'XHC-049-001', permid='XHC-049-001' WHERE num='1' and instance_id='15b7e943-fcdc-4743-a24d-99897dc4753d';UPDATE clean_minicensus_people SET pid = 'XHC-049-002', permid='XHC-049-002' WHERE num='2' and instance_id='15b7e943-fcdc-4743-a24d-99897dc4753d';UPDATE clean_minicensus_people SET pid = 'XHC-049-003', permid='XHC-049-003' WHERE num='3' and instance_id='15b7e943-fcdc-4743-a24d-99897dc4753d';UPDATE clean_minicensus_people SET pid = 'XHC-049-004', permid='XHC-049-004' WHERE num='4' and instance_id='15b7e943-fcdc-4743-a24d-99897dc4753d';UPDATE clean_minicensus_people SET pid = 'XHC-049-005', permid='XHC-049-005' WHERE num='5' and instance_id='15b7e943-fcdc-4743-a24d-99897dc4753d';UPDATE clean_minicensus_people SET pid = 'XHC-049-006', permid='XHC-049-006' WHERE num='6' and instance_id='15b7e943-fcdc-4743-a24d-99897dc4753d'", who = 'Xing Brew') 

implement(id = 'repeat_hh_id_048926bf-a0ec-43ef-9402-6de3537c9155,176409da-cf39-4569-8154-931b99811dfb', query = "UPDATE clean_minicensus_main SET hh_id='JSG-069' WHERE instance_id='176409da-cf39-4569-8154-931b99811dfb';UPDATE clean_minicensus_people SET pid = 'JSG-069-001', permid='JSG-069-001' WHERE num='1' and instance_id='176409da-cf39-4569-8154-931b99811dfb';UPDATE clean_minicensus_people SET pid = 'JSG-069-002', permid='JSG-069-002' WHERE num='2' and instance_id='176409da-cf39-4569-8154-931b99811dfb';UPDATE clean_minicensus_people SET pid = 'JSG-069-003', permid='JSG-069-003' WHERE num='3' and instance_id='176409da-cf39-4569-8154-931b99811dfb';UPDATE clean_minicensus_people SET pid = 'JSG-069-004', permid='JSG-069-004' WHERE num='4' and instance_id='176409da-cf39-4569-8154-931b99811dfb'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_05873a9f-7ab7-4b60-9b40-855c4594956d,2126ef36-c2b0-4e63-ab53-3ff8e5bca0a8', query = "UPDATE clean_minicensus_main SET hh_id='SAO-036' WHERE instance_id='2126ef36-c2b0-4e63-ab53-3ff8e5bca0a8';UPDATE clean_minicensus_people SET pid = 'SAO-036-001', permid='SAO-036-001' WHERE num='1' and instance_id='2126ef36-c2b0-4e63-ab53-3ff8e5bca0a8';UPDATE clean_minicensus_people SET pid = 'SAO-036-002', permid='SAO-036-002' WHERE num='2' and instance_id='2126ef36-c2b0-4e63-ab53-3ff8e5bca0a8';UPDATE clean_minicensus_people SET pid = 'SAO-036-003', permid='SAO-036-003' WHERE num='3' and instance_id='2126ef36-c2b0-4e63-ab53-3ff8e5bca0a8';UPDATE clean_minicensus_people SET pid = 'SAO-036-004', permid='SAO-036-004' WHERE num='4' and instance_id='2126ef36-c2b0-4e63-ab53-3ff8e5bca0a8'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_00277c2f-6b03-4c70-8d11-ecf40e624a30,cca170be-e479-4028-be56-b4fc39db272b', query = "UPDATE clean_minicensus_main SET hh_id='PZX-051' WHERE instance_id='cca170be-e479-4028-be56-b4fc39db272b';UPDATE clean_minicensus_people SET pid = 'PZX-051-001', permid='PZX-051-001' WHERE num='1' and instance_id='cca170be-e479-4028-be56-b4fc39db272b';UPDATE clean_minicensus_people SET pid = 'PZX-051-002', permid='PZX-051-002' WHERE num='2' and instance_id='cca170be-e479-4028-be56-b4fc39db272b';UPDATE clean_minicensus_people SET pid = 'PZX-051-003', permid='PZX-051-003' WHERE num='3' and instance_id='cca170be-e479-4028-be56-b4fc39db272b';UPDATE clean_minicensus_people SET pid = 'PZX-051-004', permid='PZX-051-004' WHERE num='4' and instance_id='cca170be-e479-4028-be56-b4fc39db272b'" , who = 'Xing Brew')
implement(id = 'repeat_hh_id_0e6115ec-290f-4f46-b14d-4b5f4bcdeab6,c7141d50-8852-4374-b792-48b5ed3624b0', query = "UPDATE clean_minicensus_main SET hh_id='SIT-095' WHERE instance_id='c7141d50-8852-4374-b792-48b5ed3624b0';UPDATE clean_minicensus_people SET pid = 'SIT-095-001', permid='SIT-095-001' WHERE num='1' and instance_id='c7141d50-8852-4374-b792-48b5ed3624b0';UPDATE clean_minicensus_people SET pid = 'SIT-095-002', permid='SIT-095-002' WHERE num='2' and instance_id='c7141d50-8852-4374-b792-48b5ed3624b0';UPDATE clean_minicensus_people SET pid = 'SIT-095-003', permid='SIT-095-003' WHERE num='3' and instance_id='c7141d50-8852-4374-b792-48b5ed3624b0'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_1216457a-9b98-45f0-9d25-f5ad1e228ee6,3a8bbd3c-6306-49c4-8d75-8beece8fd701', query = "UPDATE clean_minicensus_main SET hh_id='CUX-091' WHERE instance_id='1216457a-9b98-45f0-9d25-f5ad1e228ee6';UPDATE clean_minicensus_people SET pid = 'CUX-091-001', permid='CUX-091-001' WHERE num='1' and instance_id='1216457a-9b98-45f0-9d25-f5ad1e228ee6'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_185fe382-638e-4636-8602-1dc7f3f056e2,d7b35a4d-dc35-4e45-89e0-25b993604dfd', query = "UPDATE clean_minicensus_main SET hh_id='XMO-023' WHERE instance_id='185fe382-638e-4636-8602-1dc7f3f056e2';UPDATE clean_minicensus_people SET pid = 'XMO-023-001', permid='XMO-023-001' WHERE num='1' and instance_id='185fe382-638e-4636-8602-1dc7f3f056e2';UPDATE clean_minicensus_people SET pid = 'XMO-023-002', permid='XMO-023-002' WHERE num='2' and instance_id='185fe382-638e-4636-8602-1dc7f3f056e2';UPDATE clean_minicensus_people SET pid = 'XMO-023-003', permid='XMO-023-003' WHERE num='3' and instance_id='185fe382-638e-4636-8602-1dc7f3f056e2';UPDATE clean_minicensus_people SET pid = 'XMO-023-004', permid='XMO-023-004' WHERE num='4' and instance_id='185fe382-638e-4636-8602-1dc7f3f056e2'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_18b86833-d590-4275-a30c-3c48e92cff42,e3a82544-a414-460b-8210-542ce6bdb8d1', query = "UPDATE clean_minicensus_main SET hh_id='XMM-102' WHERE instance_id='18b86833-d590-4275-a30c-3c48e92cff42';UPDATE clean_minicensus_people SET pid = 'XMM-102-001', permid='XMM-102-001' WHERE num='1' and instance_id='18b86833-d590-4275-a30c-3c48e92cff42';UPDATE clean_minicensus_people SET pid = 'XMM-102-002', permid='XMM-102-002' WHERE num='2' and instance_id='18b86833-d590-4275-a30c-3c48e92cff42';UPDATE clean_minicensus_people SET pid = 'XMM-102-003', permid='XMM-102-003' WHERE num='3' and instance_id='18b86833-d590-4275-a30c-3c48e92cff42';UPDATE clean_minicensus_people SET pid = 'XMM-102-004', permid='XMM-102-004' WHERE num='4' and instance_id='18b86833-d590-4275-a30c-3c48e92cff42';UPDATE clean_minicensus_people SET pid = 'XMM-102-005', permid='XMM-102-005' WHERE num='5' and instance_id='18b86833-d590-4275-a30c-3c48e92cff42';UPDATE clean_minicensus_people SET pid = 'XMM-102-006', permid='XMM-102-006' WHERE num='6' and instance_id='18b86833-d590-4275-a30c-3c48e92cff42';UPDATE clean_minicensus_people SET pid = 'XMM-102-007', permid='XMM-102-007' WHERE num='7' and instance_id='18b86833-d590-4275-a30c-3c48e92cff42'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_1c87fd8e-981e-4ee5-bc78-f4ce273fa671,a7a2d72c-75b7-43fc-8faf-5f2e159a04cf', query = "UPDATE clean_minicensus_main SET hh_id='ZVB-038' WHERE instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-001', permid='ZVB-038-001' WHERE num='1' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-002', permid='ZVB-038-002' WHERE num='2' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-003', permid='ZVB-038-003' WHERE num='3' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-004', permid='ZVB-038-004' WHERE num='4' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-005', permid='ZVB-038-005' WHERE num='5' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-006', permid='ZVB-038-006' WHERE num='6' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-007', permid='ZVB-038-007' WHERE num='7' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-008', permid='ZVB-038-008' WHERE num='8' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf';UPDATE clean_minicensus_people SET pid = 'ZVB-038-009', permid='ZVB-038-009' WHERE num='9' and instance_id='a7a2d72c-75b7-43fc-8faf-5f2e159a04cf'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_27a3682e-94d9-472d-9151-ca824e5c62c5,daa38a0b-7b3c-430a-897a-41a09ac6fb8a', query = "UPDATE clean_minicensus_main SET hh_id='DFO-052' WHERE instance_id='daa38a0b-7b3c-430a-897a-41a09ac6fb8a';UPDATE clean_minicensus_people SET pid = 'DFO-052-001', permid='DFO-052-001' WHERE num='1' and instance_id='daa38a0b-7b3c-430a-897a-41a09ac6fb8a';UPDATE clean_minicensus_people SET pid = 'DFO-052-002', permid='DFO-052-002' WHERE num='2' and instance_id='daa38a0b-7b3c-430a-897a-41a09ac6fb8a';UPDATE clean_minicensus_people SET pid = 'DFO-052-003', permid='DFO-052-003' WHERE num='3' and instance_id='daa38a0b-7b3c-430a-897a-41a09ac6fb8a';UPDATE clean_minicensus_people SET pid = 'DFO-052-004', permid='DFO-052-004' WHERE num='4' and instance_id='daa38a0b-7b3c-430a-897a-41a09ac6fb8a';UPDATE clean_minicensus_people SET pid = 'DFO-052-005', permid='DFO-052-005' WHERE num='5' and instance_id='daa38a0b-7b3c-430a-897a-41a09ac6fb8a'" , who = 'Xing Brew')
implement(id = 'repeat_hh_id_285acbe4-9219-47ff-b949-42b9ad716e7f,33145e0d-33a5-432d-bd76-a871c878b84b', query = "UPDATE clean_minicensus_main SET hh_id='DDX-053' WHERE instance_id='285acbe4-9219-47ff-b949-42b9ad716e7f';UPDATE clean_minicensus_people SET pid = 'DDX-053-001', permid='DDX-053-001' WHERE num='1' and instance_id='285acbe4-9219-47ff-b949-42b9ad716e7f';UPDATE clean_minicensus_people SET pid = 'DDX-053-002', permid='DDX-053-002' WHERE num='2' and instance_id='285acbe4-9219-47ff-b949-42b9ad716e7f';UPDATE clean_minicensus_people SET pid = 'DDX-053-003', permid='DDX-053-003' WHERE num='3' and instance_id='285acbe4-9219-47ff-b949-42b9ad716e7f';UPDATE clean_minicensus_people SET pid = 'DDX-053-004', permid='DDX-053-004' WHERE num='4' and instance_id='285acbe4-9219-47ff-b949-42b9ad716e7f';UPDATE clean_minicensus_people SET pid = 'DDX-053-005', permid='DDX-053-005' WHERE num='5' and instance_id='285acbe4-9219-47ff-b949-42b9ad716e7f'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_32daad3f-b428-4a04-b5f0-c4bc2256764a,a6de863f-d45a-4129-92cc-4186f477136b', query = "UPDATE clean_minicensus_main SET hh_id='PXA-048' WHERE instance_id='a6de863f-d45a-4129-92cc-4186f477136b';UPDATE clean_minicensus_people SET pid = 'PXA-048-001', permid='PXA-048-001' WHERE num='1' and instance_id='a6de863f-d45a-4129-92cc-4186f477136b';UPDATE clean_minicensus_people SET pid = 'PXA-048-002', permid='PXA-048-002' WHERE num='2' and instance_id='a6de863f-d45a-4129-92cc-4186f477136b';UPDATE clean_minicensus_people SET pid = 'PXA-048-003', permid='PXA-048-003' WHERE num='3' and instance_id='a6de863f-d45a-4129-92cc-4186f477136b';UPDATE clean_minicensus_people SET pid = 'PXA-048-004', permid='PXA-048-004' WHERE num='4' and instance_id='a6de863f-d45a-4129-92cc-4186f477136b';UPDATE clean_minicensus_people SET pid = 'PXA-048-005', permid='PXA-048-005' WHERE num='5' and instance_id='a6de863f-d45a-4129-92cc-4186f477136b';UPDATE clean_minicensus_people SET pid = 'PXA-048-006', permid='PXA-048-006' WHERE num='6' and instance_id='a6de863f-d45a-4129-92cc-4186f477136b';UPDATE clean_minicensus_people SET pid = 'PXA-048-007', permid='PXA-048-007' WHERE num='7' and instance_id='a6de863f-d45a-4129-92cc-4186f477136b'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_331a332a-2750-4ae1-b909-2ef311965521,8b3eac42-8599-4be8-b8db-b3a665ae62d0', query = "UPDATE clean_minicensus_main SET hh_id='CCC-003' WHERE instance_id='8b3eac42-8599-4be8-b8db-b3a665ae62d0';UPDATE clean_minicensus_people SET pid = 'CCC-003-001', permid='CCC-003-001' WHERE num='1' and instance_id='8b3eac42-8599-4be8-b8db-b3a665ae62d0';UPDATE clean_minicensus_people SET pid = 'CCC-003-002', permid='CCC-003-002' WHERE num='2' and instance_id='8b3eac42-8599-4be8-b8db-b3a665ae62d0';UPDATE clean_minicensus_people SET pid = 'CCC-003-003', permid='CCC-003-003' WHERE num='3' and instance_id='8b3eac42-8599-4be8-b8db-b3a665ae62d0';UPDATE clean_minicensus_people SET pid = 'CCC-003-004', permid='CCC-003-004' WHERE num='4' and instance_id='8b3eac42-8599-4be8-b8db-b3a665ae62d0';UPDATE clean_minicensus_people SET pid = 'CCC-003-005', permid='CCC-003-005' WHERE num='5' and instance_id='8b3eac42-8599-4be8-b8db-b3a665ae62d0';UPDATE clean_minicensus_people SET pid = 'CCC-003-006', permid='CCC-003-006' WHERE num='6' and instance_id='8b3eac42-8599-4be8-b8db-b3a665ae62d0';UPDATE clean_minicensus_people SET pid = 'CCC-003-007', permid='CCC-003-007' WHERE num='7' and instance_id='8b3eac42-8599-4be8-b8db-b3a665ae62d0'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_3890ab39-af74-4ffc-ae57-a4dfca68e879,84975cb5-3fde-42cb-8e16-f03aba8aba0b', query = "UPDATE clean_minicensus_main SET hh_id='NAV-025' WHERE instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-001', permid='NAV-025-001' WHERE num='1' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-002', permid='NAV-025-002' WHERE num='2' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-003', permid='NAV-025-003' WHERE num='3' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-004', permid='NAV-025-004' WHERE num='4' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-005', permid='NAV-025-005' WHERE num='5' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-006', permid='NAV-025-006' WHERE num='6' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-007', permid='NAV-025-007' WHERE num='7' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-008', permid='NAV-025-008' WHERE num='8' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-009', permid='NAV-025-009' WHERE num='9' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-010', permid='NAV-025-010' WHERE num='10' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-011', permid='NAV-025-011' WHERE num='11' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-012', permid='NAV-025-012' WHERE num='12' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b';UPDATE clean_minicensus_people SET pid = 'NAV-025-013', permid='NAV-025-013' WHERE num='13' and instance_id='84975cb5-3fde-42cb-8e16-f03aba8aba0b'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_3a2396c2-eacd-4534-b969-69da74d2a8e9,8d3ed037-7e7d-4efe-a813-17fe0896309d', query = "UPDATE clean_minicensus_main SET hh_id='JON-015' WHERE instance_id='8d3ed037-7e7d-4efe-a813-17fe0896309d';UPDATE clean_minicensus_people SET pid = 'JON-015-001', permid='JON-015-001' WHERE num='1' and instance_id='8d3ed037-7e7d-4efe-a813-17fe0896309d';UPDATE clean_minicensus_people SET pid = 'JON-015-002', permid='JON-015-002' WHERE num='2' and instance_id='8d3ed037-7e7d-4efe-a813-17fe0896309d';UPDATE clean_minicensus_people SET pid = 'JON-015-003', permid='JON-015-003' WHERE num='3' and instance_id='8d3ed037-7e7d-4efe-a813-17fe0896309d';UPDATE clean_minicensus_people SET pid = 'JON-015-004', permid='JON-015-004' WHERE num='4' and instance_id='8d3ed037-7e7d-4efe-a813-17fe0896309d';UPDATE clean_minicensus_people SET pid = 'JON-015-005', permid='JON-015-005' WHERE num='5' and instance_id='8d3ed037-7e7d-4efe-a813-17fe0896309d';UPDATE clean_minicensus_people SET pid = 'JON-015-006', permid='JON-015-006' WHERE num='6' and instance_id='8d3ed037-7e7d-4efe-a813-17fe0896309d';UPDATE clean_minicensus_people SET pid = 'JON-015-007', permid='JON-015-007' WHERE num='7' and instance_id='8d3ed037-7e7d-4efe-a813-17fe0896309d'", who = 'Xing Brew')

### VA FIXES ###

iid = "'ff7a7064-2489-47cc-8d2a-1965e0587c76'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'43afb427-c306-46f2-997b-83e4435c0811'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'7cb1a7d8-ee77-496a-9aac-65984adf19d8'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'a8e033b3-a462-42f4-9688-8fbec0d3fac0'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'9e362517-93e9-41b7-a59a-66e2e242b0f2'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'b7fbb56d-3f6d-4013-adfd-63001119ffb2'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'9e362517-93e9-41b7-a59a-66e2e242b0f2'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'5b613404-9ac0-4ea9-bda1-209f073ac5f6'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'c52d0cc4-8e89-4a8c-a76b-00caac388bb3'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'6dde710b-a086-4a52-87bf-aad47e848da4'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'304dafd6-f75f-4015-aac5-8c1450cc1711'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'9795d612-b1b8-4631-8ae9-58b48844c0ae'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'304dafd6-f75f-4015-aac5-8c1450cc1711'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'24f504e6-db95-4677-b7c0-e337b83da1b2'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'f40af921-825e-481d-8eb4-31170b16d9db'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'bfb49e83-3af5-45c1-8c5e-c94bdf86ee3e'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'861ca56e-6b78-4a96-b049-11f8ae781aeb'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'6293b81b-24b1-459a-bc40-dc71569e4b1f'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'7b1c34f1-ca4d-4716-ad38-e2264b1763f9'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'67106dc9-8e4f-4fdb-a93a-919828c01fbb'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'4f710a4f-c1c8-4eb3-ab81-2d5a83ad6a80'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'f837bd59-1fed-4349-a443-0b422bc665d1'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'d06cc030-6448-4932-9347-d99eec204850'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'cf93fa79-0fc3-4d77-8cd6-62b305d7cffe'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'9cdd32c0-8e57-4bae-a311-6512f65f6599'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'9b375459-7183-45b6-81a0-8444501512e8'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'9b375459-7183-45b6-81a0-8444501512e8'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'e6bac960-b238-4137-90fa-7b7f06eb8778'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'8bd23948-ba2a-4f90-8a9b-0167e01a5408'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'74dfe6c6-7d62-4398-86da-e034da2f80c9'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'717b9ff5-fc46-4e97-a280-745f7b459111'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'0c1956e4-281f-48b2-aca4-4f02b5a58c84'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'a17b7a47-6741-4936-a020-42d3b37f63f2'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'e7b9901e-84f6-4c3a-8c8c-acb0c08a6913'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'3eb0c383-c7a0-42b0-b0ee-e69a13a28d1a'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'5e4eea37-1b88-42bc-bb4e-b7d1fecd0aba'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'8cc570d8-b18c-451f-8278-47ad50c92717'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'27ec3d85-4ff8-4276-8308-2d3a72061275'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'a85741ad-37df-454a-9f7a-f809e1d34f26'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'2bd207df-0e3d-46bf-aeb1-7e1e88fa7d5d'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'70afb03d-0ec9-4504-a02d-c37d589a9548'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'87cfb23e-5e2d-4dec-91ac-cffeca0dd99f'"
implement(id = None, query = "UPDATE clean_minicensus_main SET any_deaths_past_year='No', how_many_deaths=NULL WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + ";", who = 'Xing Brew')

# households with multiple deaths, where at least one should be deleted
iid = "'a562f9ad-5e3e-46b0-a5c0-62d347b30535'"
implement(id = None, query = "UPDATE clean_minicensus_main SET how_many_deaths='1' WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + " and death_number='1'; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + " and death_number='2';", who = 'Xing Brew')

iid = "'b4f682b9-9e28-4def-a04c-75dee495eeed'"
implement(id = None, query = "UPDATE clean_minicensus_main SET how_many_deaths='1' WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + " and death_number='1';", who = 'Xing Brew')

iid = "'c4dd69e3-9f00-4935-93b6-ad2eef6fb0af'"
implement(id = None, query = "UPDATE clean_minicensus_main SET how_many_deaths='1' WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + " and death_number='1';", who = 'Xing Brew')

iid = "'5ca40c5e-1972-4098-8210-d5e5947cc2d1'"
implement(id = None, query = "UPDATE clean_minicensus_main SET how_many_deaths='1' WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + " and death_number='2';", who = 'Xing Brew')

iid = "'b7717b99-b646-4238-ae0e-d3950c1b453a'"
implement(id = None, query = "UPDATE clean_minicensus_main SET how_many_deaths='1' WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + " and death_number='2';", who = 'Xing Brew')

iid = "'bc8f9381-35b6-44ad-bbfb-d4dee20b5f75'"
implement(id = None, query = "UPDATE clean_minicensus_main SET how_many_deaths='1' WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + " and death_number='1';", who = 'Xing Brew')

iid = "'be6ab64d-364a-47df-8f59-a1db152001bf'"
implement(id = None, query = "UPDATE clean_minicensus_main SET how_many_deaths='2' WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + " and death_number='1';", who = 'Xing Brew')

# Dec 27 fixes
implement(id = 'repeat_hh_id_b42bb9d0-b6cd-49eb-b80c-f7c6386fa0fb,b9a01cfb-2bd8-48a7-b434-2a15adacff87', query = "UPDATE clean_minicensus_main SET hh_id='ADX-068' WHERE instance_id='b42bb9d0-b6cd-49eb-b80c-f7c6386fa0fb';UPDATE clean_minicensus_people SET pid = 'ADX-068-001', permid='ADX-068-001' WHERE num='1' and instance_id='b42bb9d0-b6cd-49eb-b80c-f7c6386fa0fb';UPDATE clean_minicensus_people SET pid = 'ADX-068-002', permid='ADX-068-002' WHERE num='2' and instance_id='b42bb9d0-b6cd-49eb-b80c-f7c6386fa0fb';UPDATE clean_minicensus_people SET pid = 'ADX-068-003', permid='ADX-068-003' WHERE num='3' and instance_id='b42bb9d0-b6cd-49eb-b80c-f7c6386fa0fb';UPDATE clean_minicensus_people SET pid = 'ADX-068-004', permid='ADX-068-004' WHERE num='4' and instance_id='b42bb9d0-b6cd-49eb-b80c-f7c6386fa0fb';UPDATE clean_minicensus_people SET pid = 'ADX-068-005', permid='ADX-068-005' WHERE num='5' and instance_id='b42bb9d0-b6cd-49eb-b80c-f7c6386fa0fb';UPDATE clean_minicensus_people SET pid = 'ADX-068-006', permid='ADX-068-006' WHERE num='6' and instance_id='b42bb9d0-b6cd-49eb-b80c-f7c6386fa0fb'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_85ebe109-67a1-4981-a1db-910ef99e5852,78178b40-db0b-402a-9165-13c0ffd61bbc', query = "UPDATE clean_minicensus_main SET hh_id='ADX-128' WHERE instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-001', permid='ADX-128-001' WHERE num='1' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-002', permid='ADX-128-002' WHERE num='2' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-003', permid='ADX-128-003' WHERE num='3' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-004', permid='ADX-128-004' WHERE num='4' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-905', permid='ADX-128-905' WHERE num='5' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-006', permid='ADX-128-006' WHERE num='6' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_9f3a21e8-ea05-44a8-82d3-1b7d22f06c4a,552f8a64-0ed2-470b-a212-825d410297ff', query = "UPDATE clean_minicensus_main SET hh_id='AGO-047' WHERE instance_id='9f3a21e8-ea05-44a8-82d3-1b7d22f06c4a';UPDATE clean_minicensus_people SET pid = 'AGO-047-001', permid='AGO-047-001' WHERE num='1' and instance_id='9f3a21e8-ea05-44a8-82d3-1b7d22f06c4a';UPDATE clean_minicensus_people SET pid = 'AGO-047-002', permid='AGO-047-002' WHERE num='2' and instance_id='9f3a21e8-ea05-44a8-82d3-1b7d22f06c4a';UPDATE clean_minicensus_people SET pid = 'AGO-047-003', permid='AGO-047-003' WHERE num='3' and instance_id='9f3a21e8-ea05-44a8-82d3-1b7d22f06c4a';UPDATE clean_minicensus_people SET pid = 'AGO-047-004', permid='AGO-047-004' WHERE num='4' and instance_id='9f3a21e8-ea05-44a8-82d3-1b7d22f06c4a';UPDATE clean_minicensus_people SET pid = 'AGO-047-005', permid='AGO-047-005' WHERE num='5' and instance_id='9f3a21e8-ea05-44a8-82d3-1b7d22f06c4a';UPDATE clean_minicensus_people SET pid = 'AGO-047-006', permid='AGO-047-006' WHERE num='6' and instance_id='9f3a21e8-ea05-44a8-82d3-1b7d22f06c4a'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_5ea54979-b7db-41b5-88ab-fdd7037d9a83,81fa5c46-7da4-41b7-a276-4cb60b18adb8', query = "UPDATE clean_minicensus_main SET hh_id='BRA-057' WHERE instance_id='81fa5c46-7da4-41b7-a276-4cb60b18adb8';UPDATE clean_minicensus_people SET pid = 'BRA-057-001', permid='BRA-057-001' WHERE num='1' and instance_id='81fa5c46-7da4-41b7-a276-4cb60b18adb8';UPDATE clean_minicensus_people SET pid = 'BRA-057-002', permid='BRA-057-002' WHERE num='2' and instance_id='81fa5c46-7da4-41b7-a276-4cb60b18adb8';UPDATE clean_minicensus_people SET pid = 'BRA-057-003', permid='BRA-057-003' WHERE num='3' and instance_id='81fa5c46-7da4-41b7-a276-4cb60b18adb8';UPDATE clean_minicensus_people SET pid = 'BRA-057-004', permid='BRA-057-004' WHERE num='4' and instance_id='81fa5c46-7da4-41b7-a276-4cb60b18adb8'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_6a00497b-879b-4f63-9a46-b621a78e6ee9,f6713763-de6e-4add-a2c6-bd2d2b590279', query = "UPDATE clean_minicensus_main SET hh_id='BTE-027' WHERE instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9';UPDATE clean_minicensus_people SET pid = 'BTE-027-001', permid='BTE-027-001' WHERE num='1' and instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9';UPDATE clean_minicensus_people SET pid = 'BTE-027-002', permid='BTE-027-002' WHERE num='2' and instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9';UPDATE clean_minicensus_people SET pid = 'BTE-027-003', permid='BTE-027-003' WHERE num='3' and instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9';UPDATE clean_minicensus_people SET pid = 'BTE-027-004', permid='BTE-027-004' WHERE num='4' and instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9';UPDATE clean_minicensus_people SET pid = 'BTE-027-005', permid='BTE-027-005' WHERE num='5' and instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9';UPDATE clean_minicensus_people SET pid = 'BTE-027-006', permid='BTE-027-006' WHERE num='6' and instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9';UPDATE clean_minicensus_people SET pid = 'BTE-027-007', permid='BTE-027-007' WHERE num='7' and instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9';UPDATE clean_minicensus_people SET pid = 'BTE-027-008', permid='BTE-027-008' WHERE num='8' and instance_id='6a00497b-879b-4f63-9a46-b621a78e6ee9'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_0c392d3a-aa9e-4e8a-80b7-da9fbec17168,55544be9-8343-4f75-a4f8-5ca0f596c1da', query = "UPDATE clean_minicensus_main SET hh_id='CAI-022' WHERE instance_id='55544be9-8343-4f75-a4f8-5ca0f596c1da';UPDATE clean_minicensus_people SET pid = 'CAI-022-001', permid='CAI-022-001' WHERE num='1' and instance_id='55544be9-8343-4f75-a4f8-5ca0f596c1da';UPDATE clean_minicensus_people SET pid = 'CAI-022-002', permid='CAI-022-002' WHERE num='2' and instance_id='55544be9-8343-4f75-a4f8-5ca0f596c1da';UPDATE clean_minicensus_people SET pid = 'CAI-022-003', permid='CAI-022-003' WHERE num='3' and instance_id='55544be9-8343-4f75-a4f8-5ca0f596c1da';UPDATE clean_minicensus_people SET pid = 'CAI-022-004', permid='CAI-022-004' WHERE num='4' and instance_id='55544be9-8343-4f75-a4f8-5ca0f596c1da';UPDATE clean_minicensus_people SET pid = 'CAI-022-005', permid='CAI-022-005' WHERE num='5' and instance_id='55544be9-8343-4f75-a4f8-5ca0f596c1da';UPDATE clean_minicensus_people SET pid = 'CAI-022-006', permid='CAI-022-006' WHERE num='6' and instance_id='55544be9-8343-4f75-a4f8-5ca0f596c1da';UPDATE clean_minicensus_people SET pid = 'CAI-022-007', permid='CAI-022-007' WHERE num='7' and instance_id='55544be9-8343-4f75-a4f8-5ca0f596c1da'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_49fe66a6-93a6-48a7-bdd9-1a6fb3101da0,ff157ccd-d415-4311-884e-bb4cdf4d7627', query = "UPDATE clean_minicensus_main SET hh_id='CMX-106' WHERE instance_id='49fe66a6-93a6-48a7-bdd9-1a6fb3101da0';UPDATE clean_minicensus_people SET pid = 'CMX-106-001', permid='CMX-106-001' WHERE num='1' and instance_id='49fe66a6-93a6-48a7-bdd9-1a6fb3101da0';UPDATE clean_minicensus_people SET pid = 'CMX-106-002', permid='CMX-106-002' WHERE num='2' and instance_id='49fe66a6-93a6-48a7-bdd9-1a6fb3101da0';UPDATE clean_minicensus_people SET pid = 'CMX-106-003', permid='CMX-106-003' WHERE num='3' and instance_id='49fe66a6-93a6-48a7-bdd9-1a6fb3101da0';UPDATE clean_minicensus_people SET pid = 'CMX-106-004', permid='CMX-106-004' WHERE num='4' and instance_id='49fe66a6-93a6-48a7-bdd9-1a6fb3101da0';UPDATE clean_minicensus_people SET pid = 'CMX-106-005', permid='CMX-106-005' WHERE num='5' and instance_id='49fe66a6-93a6-48a7-bdd9-1a6fb3101da0';UPDATE clean_minicensus_people SET pid = 'CMX-106-006', permid='CMX-106-006' WHERE num='6' and instance_id='49fe66a6-93a6-48a7-bdd9-1a6fb3101da0';UPDATE clean_minicensus_people SET pid = 'CMX-106-007', permid='CMX-106-007' WHERE num='7' and instance_id='49fe66a6-93a6-48a7-bdd9-1a6fb3101da0'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_6f6fece9-a10d-49b2-8748-fab204172c15,aff2fbf6-251f-4fd1-912d-1fad52f66f51', query = "UPDATE clean_minicensus_main SET hh_id='CUX-061' WHERE instance_id='aff2fbf6-251f-4fd1-912d-1fad52f66f51';UPDATE clean_minicensus_people SET pid = 'CUX-061-001', permid='CUX-061-001' WHERE num='1' and instance_id='aff2fbf6-251f-4fd1-912d-1fad52f66f51'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_431b89e6-e5df-4ae6-b870-6235a579d1e0,d9b8ddd8-0995-4228-9299-f35298bb880c', query = "UPDATE clean_minicensus_main SET hh_id='CUX-081' WHERE instance_id='431b89e6-e5df-4ae6-b870-6235a579d1e0';UPDATE clean_minicensus_people SET pid = 'CUX-081-001', permid='CUX-081-001' WHERE num='1' and instance_id='431b89e6-e5df-4ae6-b870-6235a579d1e0';UPDATE clean_minicensus_people SET pid = 'CUX-081-002', permid='CUX-081-002' WHERE num='2' and instance_id='431b89e6-e5df-4ae6-b870-6235a579d1e0';UPDATE clean_minicensus_people SET pid = 'CUX-081-003', permid='CUX-081-003' WHERE num='3' and instance_id='431b89e6-e5df-4ae6-b870-6235a579d1e0';UPDATE clean_minicensus_people SET pid = 'CUX-081-004', permid='CUX-081-004' WHERE num='4' and instance_id='431b89e6-e5df-4ae6-b870-6235a579d1e0'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_78ebf86f-3053-415a-9c3c-c6b820169a07,241cf5df-da49-432f-98f6-089dc03d3ae8', query = "UPDATE clean_minicensus_main SET hh_id='DEH-118' WHERE instance_id='241cf5df-da49-432f-98f6-089dc03d3ae8';UPDATE clean_minicensus_people SET pid = 'DEH-118-001', permid='DEH-118-001' WHERE num='1' and instance_id='241cf5df-da49-432f-98f6-089dc03d3ae8';UPDATE clean_minicensus_people SET pid = 'DEH-118-002', permid='DEH-118-002' WHERE num='2' and instance_id='241cf5df-da49-432f-98f6-089dc03d3ae8';UPDATE clean_minicensus_people SET pid = 'DEH-118-003', permid='DEH-118-003' WHERE num='3' and instance_id='241cf5df-da49-432f-98f6-089dc03d3ae8';UPDATE clean_minicensus_people SET pid = 'DEH-118-004', permid='DEH-118-004' WHERE num='4' and instance_id='241cf5df-da49-432f-98f6-089dc03d3ae8'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_55dc6c4a-b448-43c0-bd5e-b5ad0cc903bd,a38d46f4-dea4-4c14-94ee-06f4588d6703', query = "UPDATE clean_minicensus_main SET hh_id='DRX-075' WHERE instance_id='a38d46f4-dea4-4c14-94ee-06f4588d6703';UPDATE clean_minicensus_people SET pid = 'DRX-075-001', permid='DRX-075-001' WHERE num='1' and instance_id='a38d46f4-dea4-4c14-94ee-06f4588d6703';UPDATE clean_minicensus_people SET pid = 'DRX-075-002', permid='DRX-075-002' WHERE num='2' and instance_id='a38d46f4-dea4-4c14-94ee-06f4588d6703'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_73d4191f-d5de-4a00-9bb3-6493fadb8962,f478301d-972b-42f1-86a3-de7e4beeab0a', query = "UPDATE clean_minicensus_main SET hh_id='FYX-050' WHERE instance_id='73d4191f-d5de-4a00-9bb3-6493fadb8962';UPDATE clean_minicensus_people SET pid = 'FYX-050-001', permid='FYX-050-001' WHERE num='1' and instance_id='73d4191f-d5de-4a00-9bb3-6493fadb8962';UPDATE clean_minicensus_people SET pid = 'FYX-050-002', permid='FYX-050-002' WHERE num='2' and instance_id='73d4191f-d5de-4a00-9bb3-6493fadb8962';UPDATE clean_minicensus_people SET pid = 'FYX-050-003', permid='FYX-050-003' WHERE num='3' and instance_id='73d4191f-d5de-4a00-9bb3-6493fadb8962';UPDATE clean_minicensus_people SET pid = 'FYX-050-004', permid='FYX-050-004' WHERE num='4' and instance_id='73d4191f-d5de-4a00-9bb3-6493fadb8962';UPDATE clean_minicensus_people SET pid = 'FYX-050-005', permid='FYX-050-005' WHERE num='5' and instance_id='73d4191f-d5de-4a00-9bb3-6493fadb8962';UPDATE clean_minicensus_people SET pid = 'FYX-050-006', permid='FYX-050-006' WHERE num='6' and instance_id='73d4191f-d5de-4a00-9bb3-6493fadb8962'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_741cce4c-b0ad-4278-8f4a-901cfbc7e5f3,f2dfd3ea-cb78-46e9-8097-92feb21437c5', query = "UPDATE clean_minicensus_main SET hh_id='NAA-009' WHERE instance_id='f2dfd3ea-cb78-46e9-8097-92feb21437c5';UPDATE clean_minicensus_people SET pid = 'NAA-009-001', permid='NAA-009-001' WHERE num='1' and instance_id='f2dfd3ea-cb78-46e9-8097-92feb21437c5';UPDATE clean_minicensus_people SET pid = 'NAA-009-002', permid='NAA-009-002' WHERE num='2' and instance_id='f2dfd3ea-cb78-46e9-8097-92feb21437c5';UPDATE clean_minicensus_people SET pid = 'NAA-009-003', permid='NAA-009-003' WHERE num='3' and instance_id='f2dfd3ea-cb78-46e9-8097-92feb21437c5'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_7d4b0730-4d77-4f23-aea6-ad1f2b66599c,9e318158-50e1-4f56-b587-35e647478b3b', query = "UPDATE clean_minicensus_main SET hh_id='NRA-014' WHERE instance_id='7d4b0730-4d77-4f23-aea6-ad1f2b66599c';UPDATE clean_minicensus_people SET pid = 'NRA-014-001', permid='NRA-014-001' WHERE num='1' and instance_id='7d4b0730-4d77-4f23-aea6-ad1f2b66599c';UPDATE clean_minicensus_people SET pid = 'NRA-014-002', permid='NRA-014-002' WHERE num='2' and instance_id='7d4b0730-4d77-4f23-aea6-ad1f2b66599c'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_a9c4bb79-f71f-455a-8f84-c32addbc3b12,c1fcae1f-caa9-44a7-a3a6-6bbe6b2cdddc', query = "UPDATE clean_minicensus_main SET hh_id='ADX-128' WHERE instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-001', permid='ADX-128-001' WHERE num='1' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-002', permid='ADX-128-002' WHERE num='2' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-003', permid='ADX-128-003' WHERE num='3' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-004', permid='ADX-128-004' WHERE num='4' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-905', permid='ADX-128-905' WHERE num='5' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852';UPDATE clean_minicensus_people SET pid = 'ADX-128-006', permid='ADX-128-006' WHERE num='6' and instance_id='85ebe109-67a1-4981-a1db-910ef99e5852'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_1d3682a9-ed78-4962-9ca2-2ba03e2b3cf7,7af454cb-bb72-4906-a2c6-3ba701dc055f', query = "UPDATE clean_minicensus_main SET hh_id='RAP-056' WHERE instance_id='1d3682a9-ed78-4962-9ca2-2ba03e2b3cf7';UPDATE clean_minicensus_people SET pid = 'RAP-056-001', permid='RAP-056-001' WHERE num='1' and instance_id='1d3682a9-ed78-4962-9ca2-2ba03e2b3cf7';UPDATE clean_minicensus_people SET pid = 'RAP-056-002', permid='RAP-056-002' WHERE num='2' and instance_id='1d3682a9-ed78-4962-9ca2-2ba03e2b3cf7';UPDATE clean_minicensus_people SET pid = 'RAP-056-003', permid='RAP-056-003' WHERE num='3' and instance_id='1d3682a9-ed78-4962-9ca2-2ba03e2b3cf7';UPDATE clean_minicensus_people SET pid = 'RAP-056-004', permid='RAP-056-004' WHERE num='4' and instance_id='1d3682a9-ed78-4962-9ca2-2ba03e2b3cf7';UPDATE clean_minicensus_people SET pid = 'RAP-056-005', permid='RAP-056-005' WHERE num='5' and instance_id='1d3682a9-ed78-4962-9ca2-2ba03e2b3cf7'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_43437119-8c87-483b-bf16-c9e18549f928,77978417-b781-4b80-9914-e06b0bec0ca8', query = "UPDATE clean_minicensus_main SET hh_id='RFX-097' WHERE instance_id='43437119-8c87-483b-bf16-c9e18549f928';UPDATE clean_minicensus_people SET pid = 'RFX-097-001', permid='RFX-097-001' WHERE num='1' and instance_id='43437119-8c87-483b-bf16-c9e18549f928';UPDATE clean_minicensus_people SET pid = 'RFX-097-002', permid='RFX-097-002' WHERE num='2' and instance_id='43437119-8c87-483b-bf16-c9e18549f928';UPDATE clean_minicensus_people SET pid = 'RFX-097-003', permid='RFX-097-003' WHERE num='3' and instance_id='43437119-8c87-483b-bf16-c9e18549f928'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_9df26f8d-172e-4076-b115-4679bfc406ec,fbcc08c3-82d8-4dbe-ab18-6f5e5ed14774', query = "UPDATE clean_minicensus_main SET hh_id='SAS-061' WHERE instance_id='9df26f8d-172e-4076-b115-4679bfc406ec';UPDATE clean_minicensus_people SET pid = 'SAS-061-001', permid='SAS-061-001' WHERE num='1' and instance_id='9df26f8d-172e-4076-b115-4679bfc406ec';UPDATE clean_minicensus_people SET pid = 'SAS-061-002', permid='SAS-061-002' WHERE num='2' and instance_id='9df26f8d-172e-4076-b115-4679bfc406ec';UPDATE clean_minicensus_people SET pid = 'SAS-061-003', permid='SAS-061-003' WHERE num='3' and instance_id='9df26f8d-172e-4076-b115-4679bfc406ec';UPDATE clean_minicensus_people SET pid = 'SAS-061-004', permid='SAS-061-004' WHERE num='4' and instance_id='9df26f8d-172e-4076-b115-4679bfc406ec';UPDATE clean_minicensus_people SET pid = 'SAS-061-005', permid='SAS-061-005' WHERE num='5' and instance_id='9df26f8d-172e-4076-b115-4679bfc406ec'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_24537832-6a44-4fbd-ba42-57294fd7b860,47ce4ab8-0652-43e0-892d-dda34f97e980', query = "UPDATE clean_minicensus_main SET hh_id='SOA-063' WHERE instance_id='47ce4ab8-0652-43e0-892d-dda34f97e980';UPDATE clean_minicensus_people SET pid = 'SOA-063-001', permid='SOA-063-001' WHERE num='1' and instance_id='47ce4ab8-0652-43e0-892d-dda34f97e980';UPDATE clean_minicensus_people SET pid = 'SOA-063-002', permid='SOA-063-002' WHERE num='2' and instance_id='47ce4ab8-0652-43e0-892d-dda34f97e980';UPDATE clean_minicensus_people SET pid = 'SOA-063-003', permid='SOA-063-003' WHERE num='3' and instance_id='47ce4ab8-0652-43e0-892d-dda34f97e980'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_b3c41784-4dc0-465e-817e-c3b48485485d,c618e891-8258-4b7b-abcb-bc533fa64ca5', query = "UPDATE clean_minicensus_main SET hh_id='VNT-102' WHERE instance_id='b3c41784-4dc0-465e-817e-c3b48485485d';UPDATE clean_minicensus_people SET pid = 'VNT-102-001', permid='VNT-102-001' WHERE num='1' and instance_id='b3c41784-4dc0-465e-817e-c3b48485485d';UPDATE clean_minicensus_people SET pid = 'VNT-102-002', permid='VNT-102-002' WHERE num='2' and instance_id='b3c41784-4dc0-465e-817e-c3b48485485d';UPDATE clean_minicensus_people SET pid = 'VNT-102-003', permid='VNT-102-003' WHERE num='3' and instance_id='b3c41784-4dc0-465e-817e-c3b48485485d';UPDATE clean_minicensus_people SET pid = 'VNT-102-004', permid='VNT-102-004' WHERE num='4' and instance_id='b3c41784-4dc0-465e-817e-c3b48485485d';UPDATE clean_minicensus_people SET pid = 'VNT-102-005', permid='VNT-102-005' WHERE num='5' and instance_id='b3c41784-4dc0-465e-817e-c3b48485485d'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_2228f5bd-45a3-4a7d-a216-589c62ff7ba2,280ba413-17ec-4490-b659-725b825ab5cc', query = "UPDATE clean_minicensus_main SET hh_id='MUT-027' WHERE instance_id='2228f5bd-45a3-4a7d-a216-589c62ff7ba2';UPDATE clean_minicensus_people SET pid = 'MUT-027-001', permid='MUT-027-001' WHERE num='1' and instance_id='2228f5bd-45a3-4a7d-a216-589c62ff7ba2';UPDATE clean_minicensus_people SET pid = 'MUT-027-002', permid='MUT-027-002' WHERE num='2' and instance_id='2228f5bd-45a3-4a7d-a216-589c62ff7ba2';UPDATE clean_minicensus_people SET pid = 'MUT-027-003', permid='MUT-027-003' WHERE num='3' and instance_id='2228f5bd-45a3-4a7d-a216-589c62ff7ba2';UPDATE clean_minicensus_people SET pid = 'MUT-027-004', permid='MUT-027-004' WHERE num='4' and instance_id='2228f5bd-45a3-4a7d-a216-589c62ff7ba2';UPDATE clean_minicensus_people SET pid = 'MUT-027-005', permid='MUT-027-005' WHERE num='5' and instance_id='2228f5bd-45a3-4a7d-a216-589c62ff7ba2'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_a7948239-87a4-407b-ae8d-336cf41d9e9e,fa49260f-9d3e-4606-bb39-fb9df4444dee', query = "UPDATE clean_minicensus_main SET hh_id='ALR-005' WHERE instance_id='fa49260f-9d3e-4606-bb39-fb9df4444dee';UPDATE clean_minicensus_people SET pid = 'ALR-005-001', permid='ALR-005-001' WHERE num='1' and instance_id='fa49260f-9d3e-4606-bb39-fb9df4444dee';UPDATE clean_minicensus_people SET pid = 'ALR-005-002', permid='ALR-005-002' WHERE num='2' and instance_id='fa49260f-9d3e-4606-bb39-fb9df4444dee';UPDATE clean_minicensus_people SET pid = 'ALR-005-003', permid='ALR-005-003' WHERE num='3' and instance_id='fa49260f-9d3e-4606-bb39-fb9df4444dee';UPDATE clean_minicensus_people SET pid = 'ALR-005-004', permid='ALR-005-004' WHERE num='4' and instance_id='fa49260f-9d3e-4606-bb39-fb9df4444dee';UPDATE clean_minicensus_people SET pid = 'ALR-005-005', permid='ALR-005-005' WHERE num='5' and instance_id='fa49260f-9d3e-4606-bb39-fb9df4444dee';UPDATE clean_minicensus_people SET pid = 'ALR-005-006', permid='ALR-005-006' WHERE num='6' and instance_id='fa49260f-9d3e-4606-bb39-fb9df4444dee'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_7ad2da7a-a01b-4948-ad0d-75405f497c0a,930dad93-564b-40cb-97e5-1bce910e53b9', query = "UPDATE clean_minicensus_main SET hh_id='ZVA-068' WHERE instance_id='930dad93-564b-40cb-97e5-1bce910e53b9';UPDATE clean_minicensus_people SET pid = 'ZVA-068-001', permid='ZVA-068-001' WHERE num='1' and instance_id='930dad93-564b-40cb-97e5-1bce910e53b9';UPDATE clean_minicensus_people SET pid = 'ZVA-068-002', permid='ZVA-068-002' WHERE num='2' and instance_id='930dad93-564b-40cb-97e5-1bce910e53b9';UPDATE clean_minicensus_people SET pid = 'ZVA-068-003', permid='ZVA-068-003' WHERE num='3' and instance_id='930dad93-564b-40cb-97e5-1bce910e53b9';UPDATE clean_minicensus_people SET pid = 'ZVA-068-004', permid='ZVA-068-004' WHERE num='4' and instance_id='930dad93-564b-40cb-97e5-1bce910e53b9';UPDATE clean_minicensus_people SET pid = 'ZVA-068-005', permid='ZVA-068-005' WHERE num='5' and instance_id='930dad93-564b-40cb-97e5-1bce910e53b9';UPDATE clean_minicensus_people SET pid = 'ZVA-068-006', permid='ZVA-068-006' WHERE num='6' and instance_id='930dad93-564b-40cb-97e5-1bce910e53b9'", who = 'Xing Brew')
implement(id = 'repeat_hh_id_4745eaa3-b83e-460c-ac6f-9a857f005193,9cac5744-74a7-426d-b072-be6aafd2aca8', query = "UPDATE clean_minicensus_main SET hh_id='ZVA-243' WHERE instance_id='9cac5744-74a7-426d-b072-be6aafd2aca8';UPDATE clean_minicensus_people SET pid = 'ZVA-243-001', permid='ZVA-243-001' WHERE num='1' and instance_id='9cac5744-74a7-426d-b072-be6aafd2aca8';UPDATE clean_minicensus_people SET pid = 'ZVA-243-002', permid='ZVA-243-002' WHERE num='2' and instance_id='9cac5744-74a7-426d-b072-be6aafd2aca8'", who = 'Xing Brew')

iid = "'8b5097ca-958b-4f13-b4b4-98679321123f'"
implement(id = 'repeat_hh_id_9a67cf5f-bb5f-49c8-874f-ee89b8080051,b7a84346-e400-4f8a-993a-7d399a1a1b32', query = "UPDATE clean_minicensus_main SET hh_id='CFE-086' WHERE instance_id='9a67cf5f-bb5f-49c8-874f-ee89b8080051';UPDATE clean_minicensus_people SET pid = 'CFE-086-001', permid='CFE-086-001' WHERE num='1' and instance_id='9a67cf5f-bb5f-49c8-874f-ee89b8080051';UPDATE clean_minicensus_people SET pid = 'CFE-086-002', permid='CFE-086-002' WHERE num='2' and instance_id='9a67cf5f-bb5f-49c8-874f-ee89b8080051';UPDATE clean_minicensus_people SET pid = 'CFE-086-003', permid='CFE-086-003' WHERE num='3' and instance_id='9a67cf5f-bb5f-49c8-874f-ee89b8080051';UPDATE clean_minicensus_people SET pid = 'CFE-086-004', permid='CFE-086-004' WHERE num='4' and instance_id='9a67cf5f-bb5f-49c8-874f-ee89b8080051'; DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'6d16a072-74c4-4e96-bdd1-0c182daa912d'"
implement(id = 'repeat_hh_id_099b3090-100b-46b9-a81c-ff96015ade44,5b32807f-386c-42ce-ac33-ffb404a3eb02', query = "UPDATE clean_minicensus_main SET hh_id='CHS-068' WHERE instance_id='5b32807f-386c-42ce-ac33-ffb404a3eb02';UPDATE clean_minicensus_people SET pid = 'CHS-068-001', permid='CHS-068-001' WHERE num='1' and instance_id='5b32807f-386c-42ce-ac33-ffb404a3eb02';UPDATE clean_minicensus_people SET pid = 'CHS-068-002', permid='CHS-068-002' WHERE num='2' and instance_id='5b32807f-386c-42ce-ac33-ffb404a3eb02';UPDATE clean_minicensus_people SET pid = 'CHS-068-003', permid='CHS-068-003' WHERE num='3' and instance_id='5b32807f-386c-42ce-ac33-ffb404a3eb02';UPDATE clean_minicensus_people SET pid = 'CHS-068-004', permid='CHS-068-004' WHERE num='4' and instance_id='5b32807f-386c-42ce-ac33-ffb404a3eb02';UPDATE clean_minicensus_people SET pid = 'CHS-068-005', permid='CHS-068-005' WHERE num='5' and instance_id='5b32807f-386c-42ce-ac33-ffb404a3eb02';UPDATE clean_minicensus_people SET pid = 'CHS-068-006', permid='CHS-068-006' WHERE num='6' and instance_id='5b32807f-386c-42ce-ac33-ffb404a3eb02'; DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'929ad38d-edd0-42f2-87d5-033a1fd92a8a'"
implement(id = 'repeat_hh_id_0686a29f-2ea1-4080-a6de-7115f7cf77e3,d0f11ee5-586b-4fc3-addc-5b053f4eb721', query = "UPDATE clean_minicensus_main SET hh_id='CIE-096' WHERE instance_id='d0f11ee5-586b-4fc3-addc-5b053f4eb721';UPDATE clean_minicensus_people SET pid = 'CIE-096-001', permid='CIE-096-001' WHERE num='1' and instance_id='d0f11ee5-586b-4fc3-addc-5b053f4eb721';UPDATE clean_minicensus_people SET pid = 'CIE-096-002', permid='CIE-096-002' WHERE num='2' and instance_id='d0f11ee5-586b-4fc3-addc-5b053f4eb721';UPDATE clean_minicensus_people SET pid = 'CIE-096-003', permid='CIE-096-003' WHERE num='3' and instance_id='d0f11ee5-586b-4fc3-addc-5b053f4eb721';UPDATE clean_minicensus_people SET pid = 'CIE-096-004', permid='CIE-096-004' WHERE num='4' and instance_id='d0f11ee5-586b-4fc3-addc-5b053f4eb721';UPDATE clean_minicensus_people SET pid = 'CIE-096-005', permid='CIE-096-005' WHERE num='5' and instance_id='d0f11ee5-586b-4fc3-addc-5b053f4eb721';UPDATE clean_minicensus_people SET pid = 'CIE-096-006', permid='CIE-096-006' WHERE num='6' and instance_id='d0f11ee5-586b-4fc3-addc-5b053f4eb721'; DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'1ffaf7f4-d870-4a24-9257-c061f74dbe4b'"
implement(id = 'repeat_hh_id_ad68cbef-58ce-4891-9acf-907ee4f0b701,3d490eff-edd3-4a2a-92de-96eafac1c1c7', query = "UPDATE clean_minicensus_main SET hh_id='DDD-012' WHERE instance_id='ad68cbef-58ce-4891-9acf-907ee4f0b701';UPDATE clean_minicensus_people SET pid = 'DDD-012-001', permid='DDD-012-001' WHERE num='1' and instance_id='ad68cbef-58ce-4891-9acf-907ee4f0b701';UPDATE clean_minicensus_people SET pid = 'DDD-012-002', permid='DDD-012-002' WHERE num='2' and instance_id='ad68cbef-58ce-4891-9acf-907ee4f0b701';UPDATE clean_minicensus_people SET pid = 'DDD-012-003', permid='DDD-012-003' WHERE num='3' and instance_id='ad68cbef-58ce-4891-9acf-907ee4f0b701';UPDATE clean_minicensus_people SET pid = 'DDD-012-004', permid='DDD-012-004' WHERE num='4' and instance_id='ad68cbef-58ce-4891-9acf-907ee4f0b701';UPDATE clean_minicensus_people SET pid = 'DDD-012-005', permid='DDD-012-005' WHERE num='5' and instance_id='ad68cbef-58ce-4891-9acf-907ee4f0b701'; DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'547c2884-57b8-4745-848e-672a3e905bd5'"
implement(id = 'repeat_hh_id_98d91214-1444-4939-b9e9-7f964529fbb0,f0c994cb-5d45-415e-8d3b-36cc838c116f', query = "UPDATE clean_minicensus_main SET hh_id='JON-045' WHERE instance_id='98d91214-1444-4939-b9e9-7f964529fbb0';UPDATE clean_minicensus_people SET pid = 'JON-045-001', permid='JON-045-001' WHERE num='1' and instance_id='98d91214-1444-4939-b9e9-7f964529fbb0';UPDATE clean_minicensus_people SET pid = 'JON-045-002', permid='JON-045-002' WHERE num='2' and instance_id='98d91214-1444-4939-b9e9-7f964529fbb0';UPDATE clean_minicensus_people SET pid = 'JON-045-003', permid='JON-045-003' WHERE num='3' and instance_id='98d91214-1444-4939-b9e9-7f964529fbb0';UPDATE clean_minicensus_people SET pid = 'JON-045-004', permid='JON-045-004' WHERE num='4' and instance_id='98d91214-1444-4939-b9e9-7f964529fbb0';UPDATE clean_minicensus_people SET pid = 'JON-045-005', permid='JON-045-005' WHERE num='5' and instance_id='98d91214-1444-4939-b9e9-7f964529fbb0'; DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

iid = "'862ffb52-aa10-41f6-a457-7d26997bfaf4'"
implement(id = 'repeat_hh_id_76d0ee7f-60d4-4e0a-baf6-d8907415b6c6,a198e51b-b7cf-42ed-8ee6-118052f9a55a', query = "UPDATE clean_minicensus_main SET hh_id='BRS-055' WHERE instance_id='a198e51b-b7cf-42ed-8ee6-118052f9a55a';UPDATE clean_minicensus_people SET pid = 'BRS-055-001', permid='BRS-055-001' WHERE num='1' and instance_id='a198e51b-b7cf-42ed-8ee6-118052f9a55a';UPDATE clean_minicensus_people SET pid = 'BRS-055-002', permid='BRS-055-002' WHERE num='2' and instance_id='a198e51b-b7cf-42ed-8ee6-118052f9a55a';UPDATE clean_minicensus_people SET pid = 'BRS-055-003', permid='BRS-055-003' WHERE num='3' and instance_id='a198e51b-b7cf-42ed-8ee6-118052f9a55a';UPDATE clean_minicensus_people SET pid = 'BRS-055-004', permid='BRS-055-004' WHERE num='4' and instance_id='a198e51b-b7cf-42ed-8ee6-118052f9a55a';UPDATE clean_minicensus_people SET pid = 'BRS-055-005', permid='BRS-055-005' WHERE num='5' and instance_id='a198e51b-b7cf-42ed-8ee6-118052f9a55a'; DELETE FROM clean_minicensus_main WHERE instance_id=" + iid + "; DELETE FROM clean_minicensus_people WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_death_info WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_hh_sub WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_mosquito_net WHERE instance_id= " + iid + "; DELETE FROM clean_minicensus_repeat_water WHERE instance_id= " + iid + ";", who = 'Xing Brew')

implement(id = 'repeat_hh_id_c4b07dc3-fec0-4450-a84d-7947984ce945,e5a29f5c-52da-43f3-ba4e-98c965309b5e', query = "UPDATE clean_minicensus_main SET hh_id='JON-049' WHERE instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945';UPDATE clean_minicensus_people SET pid = 'JON-049-001', permid='JON-049-001' WHERE num='1' and instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945';UPDATE clean_minicensus_people SET pid = 'JON-049-002', permid='JON-049-002' WHERE num='2' and instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945';UPDATE clean_minicensus_people SET pid = 'JON-049-003', permid='JON-049-003' WHERE num='3' and instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945';UPDATE clean_minicensus_people SET pid = 'JON-049-004', permid='JON-049-004' WHERE num='4' and instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945';UPDATE clean_minicensus_people SET pid = 'JON-049-005', permid='JON-049-005' WHERE num='5' and instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945';UPDATE clean_minicensus_people SET pid = 'JON-049-006', permid='JON-049-006' WHERE num='6' and instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945';UPDATE clean_minicensus_people SET pid = 'JON-049-007', permid='JON-049-007' WHERE num='7' and instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945';UPDATE clean_minicensus_people SET pid = 'JON-049-008', permid='JON-049-008' WHERE num='8' and instance_id='c4b07dc3-fec0-4450-a84d-7947984ce945'", who = 'Xing Brew')

implement(id = 'repeat_hh_id_4a811abc-ab94-4618-979b-ad14d0fc5ed1,e90e82f9-5bb2-470b-b20a-028bb42b32ce', query = "UPDATE clean_minicensus_main SET hh_id='CUX-121' WHERE instance_id='4a811abc-ab94-4618-979b-ad14d0fc5ed1';UPDATE clean_minicensus_people SET pid = 'CUX-121-001', permid='CUX-121-001' WHERE num='1' and instance_id='4a811abc-ab94-4618-979b-ad14d0fc5ed1'; UPDATE clean_minicensus_main SET hh_id='CUX-022' WHERE instance_id='e90e82f9-5bb2-470b-b20a-028bb42b32ce';UPDATE clean_minicensus_people SET pid = 'CUX-022-001', permid='CUX-022-001' WHERE num='1' and instance_id='e90e82f9-5bb2-470b-b20a-028bb42b32ce';UPDATE clean_minicensus_people SET pid = 'CUX-022-002', permid='CUX-022-002' WHERE num='2' and instance_id='e90e82f9-5bb2-470b-b20a-028bb42b32ce';UPDATE clean_minicensus_people SET pid = 'CUX-022-003', permid='CUX-022-003' WHERE num='3' and instance_id='e90e82f9-5bb2-470b-b20a-028bb42b32ce';UPDATE clean_minicensus_people SET pid = 'CUX-022-004', permid='CUX-022-004' WHERE num='4' and instance_id='e90e82f9-5bb2-470b-b20a-028bb42b32ce';UPDATE clean_minicensus_people SET pid = 'CUX-022-005', permid='CUX-022-005' WHERE num='5' and instance_id='e90e82f9-5bb2-470b-b20a-028bb42b32ce';UPDATE clean_minicensus_people SET pid = 'CUX-022-006', permid='CUX-022-006' WHERE num='6' and instance_id='e90e82f9-5bb2-470b-b20a-028bb42b32ce'", who = 'Xing Brew')

implement(id='repeat_hh_id_enumerations_364bf66a-005b-48e9-888b-ee0a81102071,a6acb686-d510-46eb-8ca0-71488c7c3874', query = "UPDATE clean_enumerations SET agregado='CMX-102' WHERE instance_id='364bf66a-005b-48e9-888b-ee0a81102071'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_8e3b58fb-1543-4ddd-a855-4e31c434c895,951467cf-1d7f-4a05-8d4f-64fe23a1bc9d', query = "UPDATE clean_enumerations SET agregado='CTA-041' WHERE instance_id='951467cf-1d7f-4a05-8d4f-64fe23a1bc9d'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_7486bb94-7b16-4846-b08a-c073fafbc5af,b67fb882-2a75-4fec-bf00-de5a064b8abe', query = "UPDATE clean_enumerations SET agregado='CUD-125' WHERE instance_id='13db2bc3-3b14-4d75-b73b-fac0170e9361'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_20490142-67d2-4760-9382-b3331ff57579,d56a056c-5e59-4a3f-ae4b-f46f65bf1f24', query = "UPDATE clean_enumerations SET agregado='CUD-161' WHERE instance_id='d56a056c-5e59-4a3f-ae4b-f46f65bf1f24'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_b9094709-907c-42db-acbb-e8695bc3c9a6,e45d0222-29fc-42b0-840a-026c499faa46', query = "UPDATE clean_enumerations SET agregado='CUD-174' WHERE instance_id='b9094709-907c-42db-acbb-e8695bc3c9a6'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_30b92caf-ce41-4a70-af2e-de021be887ce,44bab379-bba0-485f-bada-0261c05399c7', query = "UPDATE clean_enumerations SET agregado='DDE-101' WHERE instance_id='44bab379-bba0-485f-bada-0261c05399c7'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_1091b1fa-8b09-4dae-bf00-0e293c664f35,ffd17897-f804-49c6-b465-e3cb2732a21b', query = "UPDATE clean_enumerations SET agregado='DDS-166' WHERE instance_id='ffd17897-f804-49c6-b465-e3cb2732a21b'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_970a8b2a-74c8-4277-a4dc-6d4abf52144f,b8942baa-a07c-45c7-87b3-ea32780aa2b8', query = "UPDATE clean_enumerations SET agregado='DDS-168' WHERE instance_id='970a8b2a-74c8-4277-a4dc-6d4abf52144f'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_57a15c3c-790e-4897-85a8-9b7f08271b33,deb437da-ae82-4ed0-a2c6-40674f4c2a53', query = "UPDATE clean_enumerations SET agregado='DDX-051' WHERE instance_id='57a15c3c-790e-4897-85a8-9b7f08271b33'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_369c8983-7bb9-4e50-976e-6e0b0f934f80,a438c077-d3b5-4901-92c1-641b060899bb', query = "UPDATE clean_enumerations SET agregado='EEX-041' WHERE instance_id='a438c077-d3b5-4901-92c1-641b060899bb'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_925fa03e-cbde-4198-98ca-2cde45e09626,a0f4377e-5365-4a8f-8fdc-8c5c90cde27d', query = "UPDATE clean_enumerations SET agregado='EMX-046' WHERE instance_id='925fa03e-cbde-4198-98ca-2cde45e09626'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_04e434f9-2961-476a-9995-f8ff054a9c4e,44ee2461-f762-49d1-a4ea-881c6f894070', query = "UPDATE clean_enumerations SET agregado='GUI-028' WHERE instance_id='44ee2461-f762-49d1-a4ea-881c6f894070'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_714c6902-4ab7-4694-8ff5-416048caf086,7c7d7e13-af81-41d7-babc-d6a718c2f138', query = "UPDATE clean_enumerations SET agregado='GUL-008' WHERE instance_id='714c6902-4ab7-4694-8ff5-416048caf086'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_4078668e-d010-4fcc-af66-74aef763593d,b0d4e8dc-2cac-4450-a468-fa126f24940a', query = "UPDATE clean_enumerations SET agregado='GUL-054' WHERE instance_id='4078668e-d010-4fcc-af66-74aef763593d'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_0f0a598d-ae9e-40f5-bf89-1593e61a87d9,dd975926-2faa-41c3-90c1-0d0601fa3939', query = "UPDATE clean_enumerations SET agregado='JSB-074' WHERE instance_id='dd975926-2faa-41c3-90c1-0d0601fa3939'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_0d641b57-2282-403b-a4f2-9a3dc081b167,bd3b8fc1-8af9-49a6-a3ff-bf4ea5f82bd5', query = "UPDATE clean_enumerations SET agregado='LIZ-059' WHERE instance_id='bd3b8fc1-8af9-49a6-a3ff-bf4ea5f82bd5'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_4362de21-cfc8-4949-9e08-662d221aafe8,60dca63c-3643-40c8-ad5e-4b86c76580f5', query = "UPDATE clean_enumerations SET agregado='MAU-004' WHERE instance_id='4362de21-cfc8-4949-9e08-662d221aafe8'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_037a9962-bf29-4a11-ba51-a8f392dfe499,9198fcde-5934-41ef-91e5-2c162baeeab6', query = "UPDATE clean_enumerations SET agregado='NFI-036' WHERE instance_id='037a9962-bf29-4a11-ba51-a8f392dfe499'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_020ffd7b-6c5d-4a35-babc-4d079e46090a,e7459551-747d-462d-b001-6dbe445f6c1a', query = "UPDATE clean_enumerations SET agregado='NHP-148' WHERE instance_id='e7459551-747d-462d-b001-6dbe445f6c1a'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_7e9f7eb4-1b39-4ade-bfad-2369c532e04c,88866792-b46e-46ab-91ba-12f7f57e0766', query = "UPDATE clean_enumerations SET agregado='NZA-022' WHERE instance_id='7e9f7eb4-1b39-4ade-bfad-2369c532e04c'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_aa8e8a5d-d801-41e5-911d-1de2c9fb811a,d6cc4792-e399-4479-833b-a4bb9a299c57', query = "UPDATE clean_enumerations SET agregado='PXA-049' WHERE instance_id='d6cc4792-e399-4479-833b-a4bb9a299c57'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_72af1289-88a2-40f0-8335-89bda6daced7,ad4b52ad-d554-4f68-871c-d1f05ecf8ac5', query = "UPDATE clean_enumerations SET agregado='SAC-042' WHERE instance_id='ad4b52ad-d554-4f68-871c-d1f05ecf8ac5'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_006dd7a0-2a18-4598-b600-910f8abbb82a,bdc31858-b114-4829-bb2d-5ac161aa35a0', query = "UPDATE clean_enumerations SET agregado='SNG-007' WHERE instance_id='006dd7a0-2a18-4598-b600-910f8abbb82a'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_9390de1f-e9a3-4d2a-b764-4ce1cc2d6f08,c93c1c95-4deb-4554-914d-9bc39c885d84', query = "UPDATE clean_enumerations SET agregado='SNG-025' WHERE instance_id='c93c1c95-4deb-4554-914d-9bc39c885d84'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_a368c371-0462-4fd4-8a4f-07ea3e579789,e9eaed88-0a32-4efc-9006-36a455c11ec5', query = "UPDATE clean_enumerations SET agregado='SRD-042' WHERE instance_id='a368c371-0462-4fd4-8a4f-07ea3e579789'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_3abcac01-38e4-462c-9de2-6d220b321182,7492be91-2591-456e-a255-3b489ca6d626', query = "UPDATE clean_enumerations SET agregado='AGX-014' WHERE instance_id='3abcac01-38e4-462c-9de2-6d220b321182'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_13db2bc3-3b14-4d75-b73b-fac0170e9361,66419e67-36d3-432f-b827-0a1321fbbe27', query = "UPDATE clean_enumerations SET agregado='ALR-048' WHERE instance_id='13db2bc3-3b14-4d75-b73b-fac0170e9361'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_b1339454-d29b-4752-ace7-4ee4a183c3da,c76b7e52-6236-41d0-9624-e5a83fd5ec09', query = "UPDATE clean_enumerations SET agregado='CCC-066' WHERE instance_id='c76b7e52-6236-41d0-9624-e5a83fd5ec09'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_89b4f5ac-90bf-46ff-860b-2fedaf140938,d5816ea2-d4c8-47c5-bb69-bf0af1eb80d4', query = "UPDATE clean_enumerations SET agregado='CHS-028' WHERE instance_id='d5816ea2-d4c8-47c5-bb69-bf0af1eb80d4'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_c3433b5d-ff12-4baa-bd37-b82075789116,f98dbf0d-b3f8-4fc8-b989-d82a0d6c177f', query = "UPDATE clean_enumerations SET agregado='CIM-029' WHERE instance_id='f98dbf0d-b3f8-4fc8-b989-d82a0d6c177f'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_b4e7b9d4-92fb-48a9-92c5-94b644a44c3f,e8480758-73f5-4309-9010-3f2e6fcd72de', query = "UPDATE clean_enumerations SET agregado='CIM-082' WHERE instance_id='e8480758-73f5-4309-9010-3f2e6fcd72de'", who='Xing Brew')
implement(id='repeat_hh_id_enumerations_2046c45c-ed0a-4b1e-a9dd-f2b56adaa3f9,b3b0da09-d4ea-41f3-9846-e30b5cc4d7ac', query = "UPDATE clean_enumerations SET agregado='CIM-098' WHERE instance_id='2046c45c-ed0a-4b1e-a9dd-f2b56adaa3f9'", who='Xing Brew')

implement(id = 'repeat_hh_id_0847fe9b-9c16-4a58-8446-087e9c50750e,de4ad34c-4f57-4832-bb85-4f82843a8391', query = "UPDATE clean_minicensus_main SET hh_id='JON-012' WHERE instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391';UPDATE clean_minicensus_people SET pid = 'JON-012-001', permid='JON-012-001' WHERE num='1' and instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391';UPDATE clean_minicensus_people SET pid = 'JON-012-002', permid='JON-012-002' WHERE num='2' and instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391';UPDATE clean_minicensus_people SET pid = 'JON-012-003', permid='JON-012-003' WHERE num='3' and instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391';UPDATE clean_minicensus_people SET pid = 'JON-012-004', permid='JON-012-004' WHERE num='4' and instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391';UPDATE clean_minicensus_people SET pid = 'JON-012-005', permid='JON-012-005' WHERE num='5' and instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391';UPDATE clean_minicensus_people SET pid = 'JON-012-006', permid='JON-012-006' WHERE num='6' and instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391';UPDATE clean_minicensus_people SET pid = 'JON-012-007', permid='JON-012-007' WHERE num='7' and instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391';UPDATE clean_minicensus_people SET pid = 'JON-012-008', permid='JON-012-008' WHERE num='8' and instance_id='de4ad34c-4f57-4832-bb85-4f82843a8391'", who = 'Xing Brew')

dbconn.commit()
cur.close()
dbconn.close()
