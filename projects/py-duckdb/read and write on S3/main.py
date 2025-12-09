'''
Temos como objetivo ler um csv do S3, fazer um processamento e reescreve-lo no S3 novamente em outra pasta
Resources: https://duckdb.org/docs/extensions/httpfs/s3api.html
'''

import duckdb

conn = duckdb.connect()


base_file = "s3://nina-resources/resources/synthetic_fraud_dataset.csv"
output_file = "s3://nina-resources/duckdb/consuption/synthetic"

# Setup the connection
conn.query("""
INSTALL httpfs;
LOAD httpfs;
CREATE SECRET secretaws (
    TYPE S3,
    PROVIDER CREDENTIAL_CHAIN
);
""")


# Reading the file
conn.query(f"""
    create table nina as 
    SELECT * FROM read_csv('{base_file}', header=true, delim = ',' , ignore_errors=true);
    """)


# Transfoming adding a new column
df = conn.query(f"""
    create table nina_dated as select date_trunc('month',Timestamp) as date, * from nina;
    select * from nina_dated;
""")


# Example of partitioned write
df = conn.query(f"""
    COPY nina_dated
    TO '{output_file}/partitioned' (
    FORMAT PARQUET,
    PARTITION_BY (date),
    OVERWRITE_OR_IGNORE true
    );
""")


# Example on single file write
df = conn.query(f"""
    COPY nina
    TO '{output_file}/standalone/data.parquet' (
    FORMAT PARQUET
    );
""")

print(df)