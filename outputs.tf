output "spa_bucket_arn" {
  description = "S3 Bucket ARN for sitehosting"
  value       = aws_s3_bucket.spa_bucket.arn
}
