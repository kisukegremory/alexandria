from sqlalchemy import Table, bindparam
from sqlalchemy.orm import class_mapper
from sqlalchemy.dialects.mysql import insert


def bulk_insert(records: list[Table], engine):
    mapper = class_mapper(records[0].__class__)

    stmt = insert(records[0].__class__).values(
        {c.name: bindparam(c.name) for c in mapper.columns}
    )
    with engine.begin() as conn:
        conn.execute(stmt, [orm.values() for orm in records])
