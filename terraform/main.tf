terraform {
  required_version = ">= 1.2.4"

  required_providers {
    aws = ">= 4.22.0"
  }

  backend "s3" {
    encrypt = true
    region         = "us-east-2"
    bucket         = "email.pck.terraform-state"
    key            = "blog/terraform.tfstate"
    dynamodb_table = "email.pck.terraform-lock"
  }
}

provider "aws" {
  default_tags {
    tags = {
      Project = "Blog"
    }
  }
}

resource "aws_s3_bucket" "litestream_backups" {
  bucket = "email.pck.blog.db"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "litestream_backups_encryption" {
  bucket = aws_s3_bucket.litestream_backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.litestream_backups.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "db_versioning" {
  bucket = aws_s3_bucket.litestream_backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "db_history_expiration" {
  bucket = aws_s3_bucket.litestream_backups.id

  rule {
    id = "90d-db-history"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.litestream_backups.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}

resource "aws_iam_policy" "litestream_db_access" {
  name = "litestream_s3_access"
  path = "/blog/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = "${aws_s3_bucket.litestream_backups.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.litestream_backups.arn}/*",
          "${aws_s3_bucket.litestream_backups.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_user" "litestream_db_user" {
  name = "litestream_db_user"
  path = "/blog/"
}

resource "aws_iam_policy_attachment" "attachment" {
  name       = "test-attachment"
  users      = [aws_iam_user.litestream_db_user.name]
  policy_arn = aws_iam_policy.litestream_db_access.arn
}

resource "aws_iam_access_key" "litestream_db_user_key" {
  user = aws_iam_user.litestream_db_user.name
}
