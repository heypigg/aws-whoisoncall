

# Create an S3 bucket
resource "aws_s3_bucket" "oncall_bucket" {
  bucket = "oncall-website"
}

# DynamoDB Table
resource "aws_dynamodb_table" "oncall_schedule" {
  name           = "OnCallSchedule"
  hash_key       = "ID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "ID"
    type = "S"
  }
}

# Lambda Function
resource "aws_lambda_function" "process_csv" {
  function_name = "process_csv"
  handler       = "lambda_process_csv.handler"
  runtime       = "nodejs14.x"
  
  role = "arn:aws:iam::000000000000:role/lambda-role" # You can mock this
  
  filename         = "lambda.zip" # This should be your zipped Lambda function
  source_code_hash = filebase64sha256("lambda.zip")
  
  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.oncall_schedule.name
    }
  }
}

# Create API Gateway for Lambda
resource "aws_api_gateway_rest_api" "oncall_api" {
  name = "OnCallAPI"
}

resource "aws_api_gateway_resource" "oncall_resource" {
  rest_api_id = aws_api_gateway_rest_api.oncall_api.id
  parent_id   = aws_api_gateway_rest_api.oncall_api.root_resource_id
  path_part   = "oncall"
}

resource "aws_api_gateway_method" "oncall_get" {
  rest_api_id   = aws_api_gateway_rest_api.oncall_api.id
  resource_id   = aws_api_gateway_resource.oncall_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_csv.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.oncall_api.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.oncall_api.id
  resource_id = aws_api_gateway_resource.oncall_resource.id
  http_method = aws_api_gateway_method.oncall_get.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.process_csv.invoke_arn
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "oncall_api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.oncall_api.id
  stage_name  = "test"
}
