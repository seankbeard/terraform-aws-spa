config {
  format = "junit"

  module = false
  force = false
  disabled_by_default = false

  ignore_module = {
    "app.terraform.io" = true
  }
}

rule "terraform_module_version" {
  enabled = false
}

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_unused_declarations" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

plugin "aws" {
  enabled = true
  version = "0.18.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
