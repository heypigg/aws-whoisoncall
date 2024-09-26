# Create an S3 bucket
resource "aws_s3_bucket" "oncall_bucket" {
  bucket = "oncall-website"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "whoisoncall" {
  bucket = aws_s3_bucket.oncall_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket" "log_bucket" {
#   bucket = "my-tf-log-bucket"
# }


resource "aws_s3_bucket_acl" "whoisoncall" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.oncall_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "whoisoncall" {
  bucket = aws_s3_bucket.oncall_bucket.id

  rule {
    id = "rule-1"

    # ... other transition/expiration actions ...

    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "whoisoncall" {
  bucket = aws_s3_bucket.oncall_bucket.id
  policy = data.aws_iam_policy_document.whoisoncall.json
}

data "aws_iam_policy_document" "whoisoncall" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.oncall_bucket.arn,
      "${aws_s3_bucket.oncall_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "whoisoncall" {
  bucket = aws_s3_bucket.oncall_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}