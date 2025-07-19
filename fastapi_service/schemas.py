from pydantic import BaseModel
from typing import List, Optional

class EmbeddingBase(BaseModel):
    user_id: int

class EmbeddingCreate(EmbeddingBase):
    embedding: List[float]
    device_type: str  # 'pc' or 'mb'

class EmbeddingOut(EmbeddingBase):
    embedding_pc: Optional[List[float]]
    embedding_mb: Optional[List[float]]

    class Config:
        orm_mode = True