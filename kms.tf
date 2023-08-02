resource "aws_kms_key" "waf_logs" {
  provider = aws.us-east-1

  count                    = var.waf_logging_enabled ? 1 : 0
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  description              = "${var.name} WAFv2 Logs"
  enable_key_rotation      = true
  is_enabled               = true
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = local.aws_iam_policy_document.kms_waf_logs
}

resource "aws_kms_alias" "waf_logs" {
  provider = aws.us-east-1

  count         = var.waf_logging_enabled ? 1 : 0
  name          = format("alias/%s", "aws-waf-logs-${lower(var.name)}")
  target_key_id = join("", aws_kms_key.waf_logs[*].id)
}

resource "aws_kms_key" "kms_cloudfront_logs_key" {
  count = var.logging_enabled ? 1 : 0

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  description              = "${var.name} CloudFront Logs"
  enable_key_rotation      = true
  is_enabled               = true
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = local.aws_iam_policy_document.kms_cloudfront_s3_logs
}

resource "aws_kms_alias" "kms_cloudfront_logs_alias" {
  count = var.logging_enabled ? 1 : 0

  name          = format("alias/%s", "${lower(var.name)}_cloudfront_logs_s3")
  target_key_id = join("", aws_kms_key.kms_cloudfront_logs_key[*].id)
}
