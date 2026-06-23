from datetime import datetime, timezone
from typing import TypeVar, Generic, Type, Optional, List, Dict, Any, Union, Tuple
from pydantic import BaseModel
from bson import ObjectId
from pymongo import ReturnDocument
from motor.motor_asyncio import AsyncIOMotorCollection

ModelType = TypeVar("ModelType", bound=BaseModel)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class BaseRepository(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    """
    Generic Abstract Base Repository representing database CRUD endpoints.
    Uses Motor client collections and resolves models using Pydantic validation rules.
    """
    def __init__(self, collection: AsyncIOMotorCollection, model_class: Type[ModelType]):
        self.collection = collection
        self.model_class = model_class

    async def find_by_id(self, id: Union[str, ObjectId]) -> Optional[ModelType]:
        """Query a single document matching object ID."""
        obj_id = ObjectId(id) if isinstance(id, str) else id
        document = await self.collection.find_one({"_id": obj_id})
        if document:
            return self.model_class.model_validate(document)
        return None

    async def find_one(self, filter: Dict[str, Any]) -> Optional[ModelType]:
        """Query a single document matching dynamic filters."""
        document = await self.collection.find_one(filter)
        if document:
            return self.model_class.model_validate(document)
        return None

    async def find_many(
        self,
        filter: Dict[str, Any],
        skip: int = 0,
        limit: int = 100,
        sort: Optional[List[Tuple[str, int]]] = None
    ) -> List[ModelType]:
        """Query multiple documents matching filters, sorted and paginated."""
        cursor = self.collection.find(filter).skip(skip).limit(limit)
        if sort:
            cursor = cursor.sort(sort)
        documents = await cursor.to_list(length=limit)
        return [self.model_class.model_validate(doc) for doc in documents]

    async def create(self, schema: CreateSchemaType) -> ModelType:
        """Create a new document, populating database model defaults first."""
        insert_data = schema.model_dump(by_alias=True, exclude_unset=True)
        if "_id" in insert_data and insert_data["_id"] is None:
            insert_data.pop("_id")
            
        # Instantiate Model to generate defaults (such as UUIDs, status flags, timestamps)
        model_instance = self.model_class.model_validate(insert_data)
        db_data = model_instance.model_dump(
            by_alias=True,
            exclude_none=True
        )
        if "_id" in db_data and db_data["_id"] is None:
            db_data.pop("_id")
            
        result = await self.collection.insert_one(db_data)
        db_data["_id"] = result.inserted_id
        return self.model_class.model_validate(db_data)

    async def update(
        self,
        id: Union[str, ObjectId],
        schema: Union[UpdateSchemaType, Dict[str, Any]]
    ) -> Optional[ModelType]:
        """Perform a partial update on a document using BSON $set operators."""
        obj_id = ObjectId(id) if isinstance(id, str) else id
        
        if isinstance(schema, dict):
            update_data = schema
        else:
            update_data = schema.model_dump(exclude_unset=True, by_alias=True)
            
        # Guarantee primary key cannot be altered
        update_data.pop("_id", None)
        
        if not update_data:
            return await self.find_by_id(obj_id)
            
        # Automatically update updated_at timestamp if present
        if "updated_at" in self.model_class.model_fields:
            update_data["updated_at"] = datetime.now(timezone.utc)
            
        document = await self.collection.find_one_and_update(
            {"_id": obj_id},
            {"$set": update_data},
            return_document=ReturnDocument.AFTER
        )
        if document:
            return self.model_class.model_validate(document)
        return None

    async def delete(self, id: Union[str, ObjectId]) -> bool:
        """Delete a single document matching object ID."""
        obj_id = ObjectId(id) if isinstance(id, str) else id
        result = await self.collection.delete_one({"_id": obj_id})
        return result.deleted_count > 0

    async def count(self, filter: Dict[str, Any]) -> int:
        """Count total documents matching filters."""
        return await self.collection.count_documents(filter)
