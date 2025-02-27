
# from pymongo.mongo_client import MongoClient
# from pymongo.server_api import ServerApi

# uri = ""

# # Create a new client and connect to the server
# client = MongoClient(uri, server_api=ServerApi('1'))

# db = client.todo_db
# collection = db["todo_data"]

# # Send a ping to confirm a successful connection
# try:
#     client.admin.command('ping')
#     print("Pinged your deployment. You successfully connected to MongoDB!")
# except Exception as e:
#     print(e)

from dotenv import load_dotenv
import os

load_dotenv()

# Lấy giá trị biến môi trường
URL_DATABASE  = os.getenv("URL_DATABASE")