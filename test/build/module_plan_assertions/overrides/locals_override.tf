locals {
  aws_caller_identity = {
    current = {
      account_id = "fake_account_id"
      id         = "fake_id"
    }
  }
  aws_iam_policy_document = {
    spa_bucket_policy_document      = "{\"FakeJsonKey\":\"FakeJsonValue\"}"
    spa_bucket_logs_policy_document = "{\"FakeJsonKey\":\"FakeJsonValue\"}"
    kms_cloudfront_s3_logs          = "{\"FakeJsonKey\":\"FakeJsonValue\"}"
    kms_waf_logs                    = "{\"FakeJsonKey\":\"FakeJsonValue\"}"
  }
}