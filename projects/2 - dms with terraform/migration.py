from src import db, data
from random import randint


def main(n_owners=2):
    for n in range(n_owners):
        owner = data.generate.owner(_id=n)
        print(owner)
        pets = data.generate.pets(owner_id=owner.id, n_pets = randint(1, 3))
        print(pets)

if __name__ == '__main__':
    main()