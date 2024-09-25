# Create an S3 bucket
resource "aws_s3_bucket" "oncall_bucket" {
  bucket = "oncall-website"
}