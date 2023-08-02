
resource "aws_cloudfront_distribution" "spa_cf" {
  dynamic "logging_config" {
    for_each = var.logging_enabled == true ? toset([var.logging_config]) : toset([])
    content {
      include_cookies = var.logging_enabled ? logging_config.value.include_cookies : null
      bucket          = var.logging_enabled ? aws_s3_bucket.spa_bucket_logs[0].bucket_regional_domain_name : null
      prefix          = var.logging_enabled ? logging_config.value.prefix : null
    }
  }
  origin {
    domain_name = aws_s3_bucket.spa_bucket.bucket_regional_domain_name
    origin_id   = "s3-website"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.spa_origin.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  web_acl_id          = var.waf_enabled ? aws_wafv2_web_acl.main[0].arn : null

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-website"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = []
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 3600
    default_ttl = 604800
    max_ttl     = 604800
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction
    }
  }

  ## Default CF Certificate enabled for testing
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.cert_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  # Redirect to our SPA
  /* custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  } */

  # Redirect to our SPA
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}