import mysql.connector
import csv
import os

# ----------------------------
# Database configuration
# ----------------------------
# Credentials are retrieved from environment variables for security
DB_USER = os.environ.get("DB_USER", "your_default_user")  # fallback default
DB_PASSWORD = os.environ.get("DB_PASSWORD", "your_default_password")
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_NAME = os.environ.get("DB_NAME", "ESIBioD")

config = {
    'user': DB_USER,
    'password': DB_PASSWORD,
    'host': DB_HOST,
    'database': DB_NAME,
}

# ----------------------------
# Connect to the database
# ----------------------------
connection = mysql.connector.connect(**config)

try:
    cursor = connection.cursor()
    
    # Execute query
    cursor.execute("SELECT * FROM island")
    
    # Fetch all rows
    rows = cursor.fetchall()
    
    # Get column names
    column_names = [i[0] for i in cursor.description]

    # Path to save CSV in user's home directory
    home_directory = os.path.expanduser("~")
    csv_file_path = os.path.join(home_directory, 'result_query.csv')

    # Write to CSV
    with open(csv_file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(column_names)  # Header
        writer.writerows(rows)         # Data rows

    print(f"Data saved in '{csv_file_path}'")

finally:
    # Close cursor and connection
    cursor.close()
    connection.close()

