from sqlalchemy import Column, Integer, String, JSON
from db import Base

class UserEmbedding(Base):
    __tablename__ = "user_embeddings"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, unique=True, index=True, nullable=False)
    embedding_pc = Column(JSON, nullable=True)   # Laptop
    embedding_mb = Column(JSON, nullable=True)   # Mobile