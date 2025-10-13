
import boto3 

client = boto3.cleint("secretmanager")

SRC1_INJESTION_SF= client.get("keyy")
