output "bucket_name" {
  value = aws_s3_bucket.litestream_backups.id
}

output "access_key_id" {
  value = aws_iam_access_key.litestream_db_user_key.id
}

output "access_key_secret" {
  value     = aws_iam_access_key.litestream_db_user_key.secret
  sensitive = true
}
