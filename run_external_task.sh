echo "\nDeliver Coffee Order Task: Fetch & Lock External Task"
TASK_ID=$(curl --location --fail --silent --request POST 'http://localhost:8080/engine-rest/external-task/fetchAndLock' --header 'Content-Type: application/json' --data-raw '{"workerId":"aWorkerId","maxTasks":1,"usePriority":true,"topics":[{"topicName": "deliverCoffeeOrder","lockDuration": 10000,"variables": ["orderId"]}]}' | jq -r '.[0].id')

sleep 2
echo "\nDeliver Coffee Order Task: Complete External Task"
curl --location --fail --silent --request POST "http://localhost:8080/engine-rest/external-task/$TASK_ID/complete" --header 'Content-Type: application/json' --data-raw '{"workerId": "aWorkerId","variables":{},"localVariables":{}}'