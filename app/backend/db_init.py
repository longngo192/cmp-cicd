import psycopg2
from psycopg2 import sql
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

load_dotenv()

# Thông tin kết nối (không bao gồm tên cơ sở dữ liệu)
db_params = {
    'host': os.getenv('DB_HOST'),
    'port': os.getenv('DB_PORT'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': 'postgres'  # Kết nối tới cơ sở dữ liệu mặc định của PostgreSQL
}

# Tên cơ sở dữ liệu cần tạo
db_name = os.getenv('DB_NAME')

# Tạo cơ sở dữ liệu nếu chưa tồn tại
try:
    conn = psycopg2.connect(**db_params)
    conn.set_session(autocommit=True)
    cursor = conn.cursor()
    
    # Kiểm tra xem cơ sở dữ liệu đã tồn tại chưa
    cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
    exists = cursor.fetchone()
    
    if not exists:
        cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(db_name)))
        print(f"Database {db_name} created successfully.")
    else:
        print(f"Database {db_name} already exists.")
    
    cursor.close()
    conn.close()
except Exception as e:
    print(f"Error creating database: {e}")