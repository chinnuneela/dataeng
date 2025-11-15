from mysql_conn import * 

source_tbl = """
        CREATE TABLE IF NOT EXISTS  employee_src 
        (
        emp_id INT,
        name VARCHAR(50),
        department VARCHAR(50),
        salary INT,
        effective_date DATE
        );
        """

# emplloyee_trg ( OLAP )
target_tbl = """
        CREATE TABLE IF NOT EXISTS employee_trg
        (
            emp_id INT,
            name VARCHAR(50),
            department VARCHAR(50),
            salary INT,
            effective_start_date DATE,
            effective_end_date DATE,
            flag BOOLEAN
        );
        """

# main ----------------------------------------------------------
HOST = "127.0.0.1"
USER = "root"
PASSWORD = "Paridhi@2019#"  
DATABASE = "dw_poc"
TEST_TABLE = "user_metrics"

print("-" * 50)
print("STARTING DATABASE DEMO")
print("-" * 50)

# Initialize Connection
db = ConnectDB(host=HOST, password=PASSWORD, user=USER, database=DATABASE)

db.execute_query(source_tbl)
db.execute_query(target_tbl)
