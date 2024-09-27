# Data source to get Subnets in the default VPC
data "aws_subnet" "default" {
   filter {
    name   = "tag:Name"
    values = ["yakdriver"]
  }
}