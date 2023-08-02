##### Permissions for CloudFront S3 Origin
data "aws_iam_policy_document" "spa_bucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.spa_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.spa_origin.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.spa_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.spa_origin.iam_arn]
    }
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.spa_bucket.arn,
      "${aws_s3_bucket.spa_bucket.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }

}

##### Permissions for CloudFront S3 Logs
data "aws_iam_policy_document" "spa_bucket_logs_policy_document" {
  count = var.logging_enabled ? 1 : 0

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.spa_bucket_logs[0].arn,
      "${aws_s3_bucket.spa_bucket_logs[0].arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }

}

##### IAM policy document for the CloudWatch Logs KMS key:
data "aws_iam_policy_document" "kms_waf_logs" {
  count = var.waf_logging_enabled ? 1 : 0

  statement {
    actions = ["kms:*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.aws_caller_identity.current.account_id}:root"
      ]
    }
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    resources = [
      "*"
    ]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:*:*:log-group:aws-waf-logs-${lower(var.name)}"
      ]
    }
  }
}

##### IAM policy document for CloudFront Logs S3 Bucket KMS key:

data "aws_iam_policy_document" "kms_cloudfront_s3_logs" {
  count = var.logging_enabled ? 1 : 0

  statement {
    actions = ["kms:*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.aws_caller_identity.current.account_id}:root"
      ]
    }
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        "arn:aws:cloudtrail:*:*:trail/*"
      ]
    }
  }

  statement {
    actions = [
      "kms:GenerateDataKey*",
    ]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    resources = ["*"]

  }

}

