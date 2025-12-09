from src.db import models as models
from src.db import operations as operations
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os


DB_URL = os.getenv("DB_URL")

engine = create_engine(DB_URL, echo=True)
Session = sessionmaker(bind=engine)
