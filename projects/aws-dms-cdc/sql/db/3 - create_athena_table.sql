create external table if not exists simulation_bronze (
    op string,
    last_updated_ts string,
    id bigint,
	simulation_id string,
	created date,
	email string,
	ip_address string
)
STORED AS PARQUET
LOCATION 's3://nina-bucket-s3-dms/ninadb/Simulations/'
tblproperties ("parquet.compression"="GZIP");