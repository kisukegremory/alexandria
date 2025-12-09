from pyiceberg.catalog.sql import SqlCatalog
import pyarrow.parquet as pq
import pyarrow.compute as pc

warehouse_path = 'tmp/warehouse'
catalog = SqlCatalog(
    name='default',
    **{
        "uri": f"sqlite:///{warehouse_path}/pyiceberg_catalog.db",
        "warehouse": f"file://{warehouse_path}",
    },
)
catalog.create_namespace_if_not_exists('default')


# Teste Data: curl https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-01.parquet -o tmp/yellow_tripdata_2023-01.parquet


df = pq.read_table('tmp/yellow_tripdata_2023-01.parquet')

table = catalog.create_table_if_not_exists(
    "default.taxi_dataset",
    schema=df.schema
)

table.append(df)
print(len(table.scan().to_arrow()))


# adiciona a coluna tip_per_mile
df = df.append_column("tip_per_mile", pc.divide(df["tip_amount"], df["trip_distance"]))


# atualiza o schema
with table.update_schema() as update_schema:
    update_schema.union_by_name(df.schema)

# atualiza a tabela/dados
table.overwrite(df)
print(table.scan().to_arrow())
