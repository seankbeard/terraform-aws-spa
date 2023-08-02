module "aws_spa_with_waf" {
  source = "../"

  name            = "ProjectNameEnvironment"
  aliases         = ["example.aws.domain.co.nz"]
  cert_arn        = "arn:aws:acm:us-east-1:000000000000:certificate/00000000-1111-2222-3333-444444444444"
  bucket_name     = "name-example-aws-domain-co-nz"
  logging_enabled = true
  logging_config = {
    include_cookies = false
    prefix          = null
  }
  price_class     = "PriceClass_All"
  geo_restriction = "none"

  #### WAF
  waf_enabled         = true
  default_action      = "block"
  waf_logging_enabled = true
  ip_sets_rule = [
    {
      name = "kb_allowed_ips"
      ip_set = [
        "111.222.333.88/32"
      ]
      action   = "allow"
      priority = 1
    }
  ]
}
