# This is the main IAM policy document that will be used for the Lambda role
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      # Allow Lambda to write logs to CloudWatch
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }

  statement {
    actions = [
      # Example: Allow Lambda to read/write to a specific S3 bucket
      "s3:GetObject",
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::your-bucket-name/*"
    ]
  }

  statement {
    actions = [
      # Example: Allow Lambda to interact with a specific DynamoDB table
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:dynamodb:us-east-1:${var.account_number}:table/OnCallSchedule"
    ]
  }
}

# This is the trust relationship policy for the Lambda role
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Creating the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# Attach the policy to the role
resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda_policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


