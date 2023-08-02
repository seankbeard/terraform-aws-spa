variable "aliases" {
  type        = list(string)
  description = "List of FQDNs for CloudFront Distribution"
}

variable "name" {
  type        = string
  description = "Site or Project Firendly Name"
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^[0-9A-Za-z]+$", var.name))
    error_message = "For the application_name value only a-z, A-Z and 0-9 are allowed."
  }
}

variable "cert_arn" {
  type        = string
  description = "Validated ACM Certificate ARN for FQDNs"
}

variable "bucket_name" {
  type        = string
  description = "Bucket name for site hosting"
}

variable "logging_enabled" {
  type        = bool
  default     = false
  description = "CloudFront logging enabled"
}

variable "logging_config" {
  type = object({
    include_cookies = bool
    prefix          = string
  })
  default     = null
  description = "CloudFront logging config"
}

variable "price_class" {
  type        = string
  default     = "PriceClass_All"
  description = "Price class for CloudFront deployment"
}

variable "geo_restriction" {
  type        = string
  default     = "none"
  description = "Geo restrictions for CloudFront"
}

### WAF Vars

variable "waf_enabled" {
  type        = bool
  description = "Enable WAF"
  default     = false
}

variable "scope" {
  type        = string
  description = "The scope of this Web ACL. Valid options: CLOUDFRONT, REGIONAL."
  default     = "CLOUDFRONT"
}

variable "ip_sets_rule" {
  type = list(object({
    name     = string
    ip_set   = list(string)
    priority = number
    action   = string
  }))
  description = "A rule to detect web requests coming from particular IP addresses or address ranges."
  default     = []
}

variable "waf_logging_enabled" {
  type        = bool
  description = "Whether to associate Logging resource with the WAFv2 ACL."
  default     = false
}

variable "log_destination_arns" {
  type        = list(string)
  description = "The Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL."
  default     = []
}

variable "group_rules" {
  type = list(object({
    name            = string
    arn             = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  description = "List of WAFv2 Rule Groups."
  default     = []
}

variable "default_action" {
  type        = string
  description = "The action to perform if none of the rules contained in the WebACL match."
  default     = "allow"
}