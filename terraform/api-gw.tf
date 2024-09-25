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