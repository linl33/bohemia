#!/usr/bin/python
import psycopg2
import yaml
from sqlalchemy import create_engine
from datetime import datetime, timedelta

# Read in credentials
with open(r'../credentials/credentials.yaml') as file:
    creds = yaml.load(file, Loader=yaml.FullLoader)

dbconn = psycopg2.connect(
    dbname='bohemia', 
    user = creds['psql_master_username'], 
    password = creds['psql_master_password'], 
    host = creds['endpoint'], 
    port = 5432
)
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

yesterday = (datetime.today() - timedelta(days=1))
yesterday = datetime.strftime(yesterday.date(), '%Y-%m-%d')

clean_minicensus_count = engine.execute('SELECT count(*) as records, hh_country as country FROM clean_minicensus_main WHERE todays_date = %s GROUP BY hh_country', yesterday)
clean_refusals = engine.execute('SELECT count(*) as records, country FROM clean_refusals WHERE todays_date = %s GROUP BY country', yesterday)
clean_enumerations = engine.execute('SELECT count(*) as records, country FROM clean_enumerations WHERE todays_date = %s GROUP BY country', yesterday)
clean_va = engine.execute('SELECT count(*) as records, the_country as countr FROM clean_va WHERE todays_date = %s GROUP BY the_country', yesterday)

print(f'Data count in database for date: {yesterday}\n')
print(f'Clean Minicensus main: Total, Country -> {clean_minicensus_count.fetchall()}')
print(f'Clean Refusals: Total, Country -> {clean_refusals.fetchall()}')
print(f'Clean Enumerations: Total, Country -> {clean_enumerations.fetchall()}')
print(f'Clean VA: Total, Country -> {clean_va.fetchall()}')
