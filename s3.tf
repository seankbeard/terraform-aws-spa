resource "aws_cloudfront_origin_access_identity" "spa_origin" {
  comment = "OAI for s3 website access"
}

resource "aws_s3_bucket" "spa_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "spa" {
  bucket = aws_s3_bucket.spa_bucket.bucket
  policy = local.aws_iam_policy_document.spa_bucket_policy_document
}

# Disable the use of ACL
resource "aws_s3_bucket_ownership_controls" "spa_bucket_ownership" {
  bucket = aws_s3_bucket.spa_bucket.bucket
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "spa_bucket_public_block" {
  bucket                  = aws_s3_bucket.spa_bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "spa_bucket_website_config" {
  bucket = aws_s3_bucket.spa_bucket.bucket
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "spa_bucket_ssec" {
  bucket = aws_s3_bucket.spa_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "spa_bucket_logs" {
  count = var.logging_enabled ? 1 : 0

  bucket = "logs-${var.bucket_name}"
  # Comment out if we need to protect the logs from deletion
  force_destroy = true
}

resource "aws_s3_bucket_acl" "spa_bucket_logs_acl" {
  count = var.logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.spa_bucket_logs[0].bucket
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "spa_bucket_logs_block" {
  count = var.logging_enabled ? 1 : 0

  bucket                  = aws_s3_bucket.spa_bucket_logs[0].bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "spa_bucket_logs_ssec" {
  count = var.logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.spa_bucket_logs[0].bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_cloudfront_logs_key[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "spa_bucket_logs_policy" {
  count = var.logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.spa_bucket_logs[0].bucket
  policy = local.aws_iam_policy_document.spa_bucket_logs_policy_document
}
