from src import db
import faker
from datetime import datetime

fake = faker.Faker()


def owner(_id: int) -> db.models.Owners:
    return db.models.Owners(**{
            'id': _id,
            'name': fake.name(),
            'address': fake.address(),
            'created': datetime.now()
    })

def pets(owner_id: int, n_pets: int) -> list[db.models.Pets]:
    return [db.models.Pets(**{
            'name': fake.name(),
            'birthdate': fake.date(),
            'created': datetime.now(),
            'owner_id': owner_id
    })for _ in range(n_pets)]
