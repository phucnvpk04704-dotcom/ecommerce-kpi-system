from enum import Enum


class ProductActivityType(str, Enum):
    CREATE = "CREATE"
    UPDATE = "UPDATE"
