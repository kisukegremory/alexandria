from config import ENDPOINT, PORT, USER, REGION, DBNAME
import boto3
from sqlalchemy import create_engine, event, text
from datetime import datetime
import time



engine = create_engine(
    f"postgresql+psycopg2://{USER}@{ENDPOINT}:{PORT}/{DBNAME}",
    pool_recycle=10 # Refresh connections every 10 seconds # ideal 600s -> 10min
)

# Each connect will get a new token
@event.listens_for(engine, "do_connect")
def provide_token(dialect, conn_rec, cargs, cparams):
    session = boto3.Session(profile_name='nina', region_name=REGION)
    client = session.client('rds')
    token = client.generate_db_auth_token(DBHostname=ENDPOINT, Port=PORT, DBUsername=USER, Region=REGION)
    cparams["password"] = token
    print('Connection refreshed at {}'.format(datetime.now()))


# Test connection with statement timestamp
def ping_server(conn):
    try:
        print("Database connected at {} -".format(datetime.now()),conn.execute(text("SELECT statement_timestamp()")).fetchall())
    except Exception as e:
        print("Database connection failed due to {}".format(e))

# Query every second to test if connection got refreshed
while True:
    with engine.connect() as conn:
        ping_server(conn)
        time.sleep(1)
                    