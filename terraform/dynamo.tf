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