from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, Integer, VARCHAR, DATETIME, DATE

Base = declarative_base()

class Pets(Base):
    __tablename__ = "pets"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(VARCHAR(45))
    birthdate = Column(DATE)
    created = Column(DATETIME)
    owner_id = Column(Integer, index=True)


class Owners(Base):
    __tablename__ = "owners"

    id = Column(Integer, primary_key=True)
    name = Column(VARCHAR(45))
    address = Column(VARCHAR(90))
    created = Column(DATETIME)
