from src import db, data
from random import randint
import itertools


def main(n_owners=500):
    owners = [data.generate.owner(_id=n) for n in range(n_owners)]
    db.operations.bulk_insert(owners, db.engine)

    pets = [
        data.generate.pets(owner_id=n, n_pets=randint(1, 3)) for n in range(n_owners)
    ]
    pets = list(itertools.chain(*pets))
    db.operations.bulk_insert(pets, db.engine)


if __name__ == "__main__":
    with db.engine.connect() as conn:
        db.models.metadata.create_all(conn)
    main()
