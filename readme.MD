To start setting up site, follow these steps...

1. open terminal and start localstack

```
localstack start
```


2. open another terminal and run node.js

```
node server.js
```

3. Zip Lambda Code (if it's not already zipped):

```
cd lambda_process_csv_folder
zip -r ../lambda_function.zip . -x "*.git*" "*.npmignore" "node_modules/aws-sdk/*"

```

4. Create Terraform config with dynamo, dynamo table, s3, lambda, and api gw


4. Recreate Infrastructure with Terraform - Re-run Terraform:

```
terraform init
terraform plan
terraform apply
```

7.: Ensure Resources are Recreated


DynamoDB: Ensure the DynamoDB table is created and populated with the on-call data.
You can use the AWS CLI to create the table in your LocalStack environment.

(this step can be terraformed in previous step)

```
aws --endpoint-url=http://127.0.0.1:4566 dynamodb create-table \
    --table-name OnCallSchedule \
    --attribute-definitions AttributeName=ID,AttributeType=S \
    --key-schema AttributeName=ID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

```

You can confirm that the table was created successfully by listing all the DynamoDB tables:

```
aws --endpoint-url=http://127.0.0.1:4566 dynamodb list-tables
```

If you want to inspect the table’s details, you can describe the table:

```
aws --endpoint-url=http://127.0.0.1:4566 dynamodb describe-table --table-name OnCallSchedule

```

5. Update Lambda Function Code:

```
aws --endpoint-url=http://127.0.0.1:4566 lambda update-function-code --function-name process_csv --zip-file fileb://lambda_function.zip
```


6. S3 Bucket: Ensure the S3 bucket is created and populated with any required files (e.g., output.csv).

```
aws --endpoint-url=http://127.0.0.1:4566 s3api create-bucket --bucket oncall-website
```

7. Upload Output CSV to s3 bucket

```
aws --endpoint-url=http://127.0.0.1:4566 s3 cp output.csv s3://oncall-website/output.csv

```

8. Invoke the Lambda Function (if needed for testing):

```
aws --endpoint-url=http://127.0.0.1:4566 lambda invoke --function-name process_csv --payload file://s3_event.json --cli-binary-format raw-in-base64-out response.json
```

API Gateway: Ensure the API Gateway is set up to trigger the Lambda functions.
