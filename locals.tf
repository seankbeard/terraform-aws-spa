locals {
  ## Locals for test framework
  aws_iam_policy_document = {
    spa_bucket_policy_document      = data.aws_iam_policy_document.spa_bucket_policy_document.json
    spa_bucket_logs_policy_document = try(data.aws_iam_policy_document.spa_bucket_logs_policy_document[0].json, null)
    kms_cloudfront_s3_logs          = try(data.aws_iam_policy_document.kms_cloudfront_s3_logs[0].json, null)
    kms_waf_logs                    = try(data.aws_iam_policy_document.kms_waf_logs[0].json, null)
  }
  aws_caller_identity = {
    current = {
      account_id = data.aws_caller_identity.current.account_id
      id         = data.aws_caller_identity.current.id
    }
  }
}
