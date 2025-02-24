'''
Temos como objetivo ler um csv do S3, fazer um processamento e reescreve-lo no S3 novamente em outra pasta
Resources: https://duckdb.org/docs/extensions/httpfs/s3api.html
'''

import duckdb

conn = duckdb.connect()


base_file = "resources/synthetic_fraud_dataset.csv"
output_file = "s3://nina-resources/duckdb/consuption/synthetic/"

# Setup the connection
conn.query("""
INSTALL httpfs;
LOAD httpfs;
CREATE SECRET secretaws (
    TYPE S3,
    PROVIDER CREDENTIAL_CHAIN
);
""")

conn.query(f"""
    create table nina as 
    SELECT * FROM read_csv('{base_file}', header=true, delim = ',' , ignore_errors=true);
    """)

# df = conn.query(f"""
#     COPY nina
#     TO '{output_file}' (
#     FORMAT PARQUET,
#     PARTITION_BY (Transaction_Type),
#     OVERWRITE_OR_IGNORE true
#     );
# """)

df = conn.query(f"""
    COPY nina
    TO '{output_file}data.parquet' (
    FORMAT PARQUET
    );
""")

print(df)