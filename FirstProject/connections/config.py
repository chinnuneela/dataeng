from FirstProject.connections.connect_db import connection
import boto3 

def get_secrets():
    cleint  = boto3.client("secretmanager")


    cleint.fetch("sf_user")
    cleint.fetch("sf_password")


    return { "user" : cleint.fetch("sf_user") ,
            "password" : cleint.fetch("sf_password") }

connection.close()