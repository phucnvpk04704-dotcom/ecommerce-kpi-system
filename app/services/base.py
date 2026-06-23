from typing import TypeVar, Generic, Optional, List, Any
from pydantic import BaseModel
from app.repositories.base import BaseRepository

ModelType = TypeVar("ModelType", bound=BaseModel)
RepositoryType = TypeVar("RepositoryType", bound=BaseRepository)


class BaseService(Generic[ModelType, RepositoryType]):
    """
    Generic Abstract Base Service representing standard CRUD logic.
    Delegates database access operations directly to the repository instance.
    """
    def __init__(self, repository: RepositoryType):
        self.repository = repository

    async def get_by_id(self, id: Any) -> Optional[ModelType]:
        """Fetch a single document matching object ID."""
        return await self.repository.find_by_id(id)

    async def get_many(
        self,
        filter: dict,
        skip: int = 0,
        limit: int = 100
    ) -> List[ModelType]:
        """Fetch multiple documents matching filters, sorted and paginated."""
        return await self.repository.find_many(filter, skip=skip, limit=limit)

    async def create(self, schema: Any) -> ModelType:
        """Create a new document, populating database model defaults first."""
        return await self.repository.create(schema)

    async def update(self, id: Any, schema: Any) -> Optional[ModelType]:
        """Perform a partial update on a document using BSON $set operators."""
        return await self.repository.update(id, schema)

    async def delete(self, id: Any) -> bool:
        """Delete a single document matching object ID."""
        return await self.repository.delete(id)
