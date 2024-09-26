# Lambda Function
resource "aws_lambda_function" "process_csv" {
  function_name = "process_csv"
  handler       = "lambda_process_csv.handler"
  runtime       = "nodejs14.x"
  
  role = "arn:aws:iam::000000000000:role/lambda-role" # You can mock this
  
  filename         = "../lambda/lambda_function.zip" # This should be your zipped Lambda function
  source_code_hash = filebase64sha256("lambda_function.zip")
  
  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.oncall_schedule.name
    }
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_csv.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.oncall_api.execution_arn}/*/*"
}