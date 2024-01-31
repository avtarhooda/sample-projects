from flask import Flask, request, jsonify
import pymysql
import hashlib
import os

app = Flask(__name__)

# MySQL configurations
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_USER = os.environ.get('DB_USER', 'root')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'admin@123')
DB_NAME = os.environ.get('DB_NAME', 'users_crud')
AUTH_TOKEN=''
# Establish a MySQL connection
def create_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        db=DB_NAME,
        port=3306,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )

# Hash function for password
def hash_password(password):
    return hashlib.sha1(password.encode()).hexdigest()

# Authentication middleware
def authenticate_request():
    auth_token = request.headers.get("AUTH_TOKEN")
    if not auth_token or auth_token != AUTH_TOKEN:
        return False
    return True

# Endpoint for /v1/user
@app.route('/v1/user', methods=['POST', 'PUT', 'GET', 'DELETE'])
def user():
    if not authenticate_request():
        return jsonify({'error': 'Unauthorized'}), 401

    connection = create_connection()
    if not connection:
        return jsonify({'error': 'Database connection error'}), 500

    try:
        with connection.cursor() as cursor:
            user_id = request.args.get('user_id', type=int)

            if request.method == 'POST':
                data = request.json
                username = data.get('username')
                password = data.get('password')

                hashed_password = hash_password(password)

                # Check if the username already exists
                cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
                existing_user = cursor.fetchone()

                if existing_user:
                    # Username already exists, return an error response
                    error_message = "Username already taken. Please choose a different username."
                    return jsonify({'users': [], 'errors': [error_message]})

                # If the username is not taken, proceed with user creation
                hashed_password = hash_password(password)

                sql = "INSERT INTO users (username, password) VALUES (%s, %s)"
                cursor.execute(sql, (username, hashed_password))
                connection.commit()

                user_id = cursor.lastrowid
                new_user = {'user_id': user_id, 'username': username, 'password': hashed_password}
                return jsonify({'users': [new_user], 'errors': []})

            elif request.method == 'PUT':
                data = request.json
                username = data.get('username')
                password = data.get('password')

                hashed_password = hash_password(password)

                sql = "UPDATE users SET username=%s, password=%s WHERE user_id=%s"
                cursor.execute(sql, (username, hashed_password, user_id))
                connection.commit()

                if cursor.rowcount > 0:
                    updated_user = {'user_id': user_id, 'username': username, 'password': hashed_password}
                    return jsonify({'users': [updated_user], 'errors': []})
                else:
                    return jsonify({'users': [], 'errors': ['User not found']})

            elif request.method == 'GET':
                if user_id:
                    sql = "SELECT * FROM users WHERE user_id=%s"
                    cursor.execute(sql, (user_id,))
                    user = cursor.fetchone()

                    if user:
                        return jsonify({'users': [user], 'errors': []})
                    else:
                        return jsonify({'users': [], 'errors': ['User not found']})
                else:
                    sql = "SELECT * FROM users"
                    cursor.execute(sql)
                    users = cursor.fetchall()
                    return jsonify({'users': users, 'errors': []})

            elif request.method == 'DELETE':
                if user_id:
                    sql = "DELETE FROM users WHERE user_id=%s"
                    cursor.execute(sql, (user_id,))
                    connection.commit()

                    if cursor.rowcount > 0:
                        return jsonify({'users': [], 'errors': []})
                    else:
                        return jsonify({'users': [], 'errors': ['User not found']})
                else:
                    return jsonify({'users': [], 'errors': ['User ID is required for DELETE']}), 400

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    finally:
        connection.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)