export AWS_PROFILE=nina
export QUEUE_URL=$(aws sqs get-queue-url --queue-name serverless-interaction-api-queue --region us-east-1 | jq -r .QueueUrl)
echo $QUEUE_URL

cd api && go run . && cd ../
