resource "aws_cloudwatch_log_group" "waf_logs" {
  provider = aws.us-east-1

  count             = var.waf_logging_enabled ? 1 : 0
  name              = "aws-waf-logs-${lower(var.name)}"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.waf_logs[0].arn
}
