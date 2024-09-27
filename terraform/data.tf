# Data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get Subnets in the default VPC
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}



output "subnet_ids" {
  value = data.aws_subnet_ids.default.ids
}