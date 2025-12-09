import psycopg2
import boto3
import time
from config import ENDPOINT, PORT, USER, REGION, DBNAME

session = boto3.Session(region_name=REGION)
client = session.client('rds')


token = client.generate_db_auth_token(DBHostname=ENDPOINT, Port=PORT, DBUsername=USER, Region=REGION)
print(token)
conn = psycopg2.connect(host=ENDPOINT, port=PORT, database=DBNAME, user=USER, password=token, sslrootcert="SSLCERTIFICATE")
def ping_server(conn):
    try:
        cur = conn.cursor()
        cur.execute("""SELECT statement_timestamp()""")
        query_results = cur.fetchall()
        print(query_results)
    except Exception as e:
        print("Database connection failed due to {}".format(e))

while True:
    ping_server(conn)
    time.sleep(1)