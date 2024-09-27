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
  bucket = aws_s3_bucket.oncall_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "whoisoncall" {
  bucket = aws_s3_bucket.oncall_bucket.id

  rule {
    id = "glacier"
    status = "Enabled"
    transition {
      days = 0
      storage_class = "GLACIER"
    }
    noncurrent_version_transition {
      noncurrent_days = 0
      storage_class = "GLACIER"
    }
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
      identifiers = ["${var.account_number}"]
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

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.oncall_bucket.id
  key    = "ouput_csv"
  source = "../scripts/output.csv"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("../scripts/output.csv")
}