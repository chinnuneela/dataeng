from mysql_spark import ConnectDB


HOST = "127.0.0.1"
USER = "root"
PASSWORD = "Paridhi@2019#"  
DATABASE = "dw_poc"
SOURCE_TABLE = "source_data"
TARGET_TABLE = "processed_results"

db = ConnectDB(host=HOST, password=PASSWORD, user=USER, database=DATABASE)

query1 = "insert into employee_src values(7,'golu','HR',5000,'2025-10-30')"

db.execute_query(query1)

