import mysql.connector
from mysql.connector import Error 
from abc import ABC , abstractmethod
import datetime 
import time
import random

# --- Abstract Base Class (Connection Contract) ---
class Connection(ABC):
    """Abstract Base Class defining the contract for a database connection."""

    @abstractmethod
    def create_connection(self):
        """Attempts to establish or verify the database connection."""
        pass

    @abstractmethod
    def fetch_query(self, query):
        """Executes a SELECT query and returns results."""
        pass


# --- Concrete Implementation ---
class ConnectDB(Connection):
    """Concrete implementation for connecting to and interacting with MySQL."""
    
    def __init__(self, host, user, password, database):
        print("Initialising the database configuration...")
        self.connection = None 
        self.config = {
                  'host' : host,     
                  'user' : user,
                  'password' : password,
                  'database': database
                }
        
    def create_connection(self):
        """Attempts to establish connection if one does not exist or is closed."""
        if self.connection is None or not self.connection.is_connected():
            try:
                self.connection = mysql.connector.connect(**self.config) 
                if self.connection.is_connected():
                    print("Connection Established.")
                    return True
                else:
                    return False
            except Error as e:
                print(f"Connection Error: {e}")
                self.connection = None 
                return False
        return True

    # --- Generic Execution Method (New/Core Function) ---
    def execute_query(self, query, data=None, commit=True):
        """
        Executes a generic SQL query (e.g., CREATE, DROP, UPDATE, DELETE).
        Uses parameterized queries for security if 'data' is provided.
        """
        if not self.create_connection():
            
            print("Failed to establish connection, cannot execute query.")
            return False

        curr = None
        try:
            curr = self.connection.cursor()
            if data:
                curr.execute(query, data)
            else:
                curr.execute(query)

            if commit:
                self.connection.commit()
                print(f"Query executed successfully. Rows affected: {curr.rowcount}")
            return True
            
        except Error as e:
            print(f"Error executing query: {e}")
            if self.connection and self.connection.is_connected():
                self.connection.rollback() # Rollback on error
            return False
        finally:
            if curr:
                curr.close()

    # --- Data Manipulation (DML) Methods ---

    def fetch_query(self, query): 
        """Executes a SELECT query and returns results as dictionaries."""
        if not self.create_connection():
            print("Failed to establish connection, cannot execute SELECT query.")
            return None

        curr = None
        try:    
            curr = self.connection.cursor(dictionary=True, buffered=True)
            curr.execute(query)
            result = curr.fetchall()
            return result 
        except Error as e:
            print(f"Error while fetching data: {e}")
            return None 
        finally:
            if curr:
                curr.close()

    def insert_query(self, query, data=None):
        """Wrapper for INSERT queries, ensuring parameterized execution."""
        if data is None:
             print("Warning: Insert query called without data. Using generic execute_query.")
             return self.execute_query(query)
        
        # Internally uses the safer execute_query method
        return self.execute_query(query, data=data)

    # --- Table Management (DDL) Methods ---

    def create_table(self, table_name, schema):
        """Creates a table using the provided schema string."""
        query = f"CREATE TABLE IF NOT EXISTS {table_name} ({schema})"
        print(f"Attempting to create table '{table_name}'...")
        return self.execute_query(query)
    
    def drop_table(self, table_name):
        """Drops a specified table."""
        query = f"DROP TABLE IF EXISTS {table_name}"
        print(f"Attempting to drop table '{table_name}'...")
        return self.execute_query(query)

    # --- Utility Methods ---

    def get_count(self, table_name, condition=None):
        """Returns the number of rows in a table, optionally matching a condition."""
        query = f"SELECT COUNT(*) as row_count FROM {table_name}"
        if condition:
            # Example: condition="status = 'active'"
            query += f" WHERE {condition}"
        
        result = self.fetch_query(query)
        
        if result and result[0] and 'row_count' in result[0]:
            return result[0]['row_count']
        return 0

    def close_connection(self):
        """Closes the connection safely."""
        if self.connection and self.connection.is_connected():
            self.connection.close()
            self.connection = None
            print("The db connection is now closed.") 

# -----------------------------------------------------------------------------------------------
# --- EXAMPLE USAGE ---

# Configuration (UPDATE THESE WITH YOUR ACTUAL CREDENTIALS)

def example_usage():
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

    # 1. CREATE TABLE Example
    print("\n--- 1. Creating Table ---")
    table_schema = (
        "id INT AUTO_INCREMENT PRIMARY KEY, "
        "username VARCHAR(50) NOT NULL, "
        "score INT, "
        "last_login DATETIME"
    )
    db.create_table(TEST_TABLE, table_schema)


    # 2. INSERT QUERY Example (Parameterized)
    print("\n--- 2. Inserting Data ---")
    insert_template = f"INSERT INTO {TEST_TABLE} (username, score, last_login) VALUES (%s, %s, %s)"

    # Define data tuples
    users_to_insert = [
        ("Alice", 1500, datetime.datetime.now()),
        ("Bob", 850, datetime.datetime.now() - datetime.timedelta(days=1)),
        ("Charlie", 2100, datetime.datetime.now())
    ]

    for user_data in users_to_insert:
        # Notice we use the insert_template and pass the tuple (user_data) to the function
        db.insert_query(insert_template, user_data)


    # 3. COUNT Example
    print("\n--- 3. Counting Records ---")
    total_users = db.get_count(TEST_TABLE)
    print(f"Total records in '{TEST_TABLE}': {total_users}")


    # 4. FETCH QUERY Example (SELECT)
    print("\n--- 4. Fetching Data ---")
    select_query = f"SELECT id, username, score FROM {TEST_TABLE} WHERE score > 1000"
    high_scores = db.fetch_query(select_query)
    print(f"Users with score > 1000: {high_scores}")


    # 5. EXECUTE QUERY Example (UPDATE)
    print("\n--- 5. Generic Execute Query (UPDATE) ---")
    # Query to update Bob's score
    update_query = f"UPDATE {TEST_TABLE} SET score = %s, last_login = %s WHERE username = %s"
    update_data = (1000, datetime.datetime.now(), "Bob") # New score, new login time, target user

    db.execute_query(update_query, update_data)


    # 6. FETCH QUERY to verify UPDATE
    print("\n--- 6. Verifying Update ---")
    bob_record = db.fetch_query(f"SELECT score FROM {TEST_TABLE} WHERE username = 'Bob'")
    print(f"Bob's updated score: {bob_record}")


    # 7. DROP TABLE Example
    print("\n--- 7. Dropping Table ---")
    # Uncomment the line below to drop the table after the demo is complete
    # db.drop_table(TEST_TABLE)


    # 8. Close Connection
    print("\n--- 8. Closing Connection ---")
    db.close_connection()

    print("-" * 50)
    print("DEMO COMPLETE")
    print("-" * 50)


# ---------------------------------------------

#example_usage()