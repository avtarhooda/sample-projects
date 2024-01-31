import json
import requests
import concurrent.futures
import time
import csv
import os

_outfilename = 'load_test_results.csv'
_infilename = 'output-dump_batch8.json'
requests_per_execution = 3000

with open(_infilename, 'r') as file:
    json_data = json.load(file)
    print(len(json_data))
    exit()

# Define the URL to send requests to
url = 'https://recommendation.test.com/recommendation'

# Get token from environment variable
_token = os.environ.get('_token')

headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + _token
}

results = {}


def send_request(json_obj, headers=headers):
    try:
        start_time = time.time()
        response = requests.post(url, json=json_obj, headers=headers)
        end_time = time.time()
        execution_time = end_time - start_time

        if response.status_code in [200, 201]:
            results[json_obj['requestUUID']] = {
                'ExecutionTime': execution_time,
                'ResponseTime': response.elapsed.total_seconds(),
                'StatusCode': response.status_code,
                'JSONBody': "N/A"
            }
        else:
            print(f"Request failed with status code {response.status_code}")
            results[json_obj['requestUUID']] = {
                'ExecutionTime': execution_time,
                'ResponseTime': response.elapsed.total_seconds(),
                'StatusCode': response.status_code,
                'JSONBody': json_obj
            }
    except Exception as e:
        print(f"Request failed with exception: {e}")
        results[json_obj['requestUUID']] = {
            'ExecutionTime': -1,
            'ResponseTime': -1,
            'StatusCode': -1,
            'JSONBody': json_obj
        }

total_executions = len(json_data) // requests_per_execution

for execution in range(total_executions):
    start_index = execution * requests_per_execution
    end_index = start_index + requests_per_execution
    json_objects = json_data[start_index:end_index]

    with concurrent.futures.ThreadPoolExecutor(max_workers=requests_per_execution) as executor:
        executor.map(send_request, json_objects)

# Write the results to a CSV file
with open(_outfilename, 'w', newline='') as csvfile:
    fieldnames = ['RequestUUID', 'ExecutionTime', 'ResponseTime', 'StatusCode', 'JSONBody']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    for request_uuid, result in results.items():
        writer.writerow({'RequestUUID': request_uuid, **result})
