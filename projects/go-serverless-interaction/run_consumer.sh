export AWS_PROFILE=nina
export QUEUE_URL=$(aws sqs get-queue-url --queue-name serverless-interaction-api-queue --region us-east-1 | jq -r .QueueUrl)
# aws sqs receive-message --queue-url $QUEUE_URL --region us-east-1 --max-number-of-messages 10
cd consumer && go run . && cd ../
