resource "aws_wafv2_ip_set" "ipset" {
  provider           = aws.us-east-1
  count              = length(var.ip_sets_rule)
  name               = var.ip_sets_rule[count.index].name
  addresses          = var.ip_sets_rule[count.index].ip_set
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
}

resource "aws_wafv2_web_acl" "main" {
  provider = aws.us-east-1

  count       = var.waf_enabled ? 1 : 0
  name        = "${lower(var.name)}_wafv2"
  description = "WAFv2 ACL for ${var.name} Static Website"
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = false
    metric_name                = "${var.name}WafMetrics"
  }

  dynamic "rule" {
    for_each = var.ip_sets_rule
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.ipset[index(var.ip_sets_rule, rule.value)].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = false
      }
    }
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = var.waf_enabled && var.waf_logging_enabled ? 1 : 0

  provider                = aws.us-east-1
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs[0].arn]
  resource_arn            = aws_wafv2_web_acl.main[0].arn
}