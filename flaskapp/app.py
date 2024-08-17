from flask import Flask, request, jsonify, render_template
import boto3
from botocore.exceptions import ClientError, NoCredentialsError, EndpointConnectionError

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

# Endpoint to fetch tasks
@app.route('/tasks', methods=['GET'])
def get_tasks():
    try:
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        table = dynamodb.Table('Tasks')
        response = table.scan()
        tasks = response['Items']
        return jsonify(tasks)
    except (ClientError, NoCredentialsError, EndpointConnectionError) as e:
        return jsonify({"error": "DynamoDB Connection Failed: " + str(e)}), 500

# Endpoint to create a task
@app.route('/tasks', methods=['POST'])
def create_task():
    try:
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        table = dynamodb.Table('Tasks')
        data = request.get_json()
        task_id = data['id']
        task_name = data['name']
        table.put_item(Item={'id': task_id, 'name': task_name})
        return jsonify({"message": "Task created"}), 201
    except (ClientError, NoCredentialsError, EndpointConnectionError) as e:
        return jsonify({"error": "DynamoDB Connection Failed: " + str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
