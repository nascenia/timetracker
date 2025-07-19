from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from models import UserEmbedding

async def create_or_update_embedding(db: AsyncSession, user_id: int, embedding: list, device_type: str):
    result = await db.execute(select(UserEmbedding).where(UserEmbedding.user_id == user_id))
    user_embedding = result.scalars().first()
    if not user_embedding:
        user_embedding = UserEmbedding(user_id=user_id)
        if device_type == "pc":
            user_embedding.embedding_pc = embedding
        elif device_type == "mb":
            user_embedding.embedding_mb = embedding
        db.add(user_embedding)
    else:
        if device_type == "pc":
            user_embedding.embedding_pc = embedding
        elif device_type == "mb":
            user_embedding.embedding_mb = embedding
    await db.commit()
    await db.refresh(user_embedding)
    return user_embedding

async def get_embedding(db: AsyncSession, user_id: int):
    result = await db.execute(select(UserEmbedding).where(UserEmbedding.user_id == user_id))
    return result.scalars().first()