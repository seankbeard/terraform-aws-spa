provider "aws" {
  access_key                  = "FakeAccessKeyId"
  secret_key                  = "FakeSecretAccessKey"
  skip_get_ec2_platforms      = true
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  region                      = "ap-southeast-2"
}
provider "aws" {
  alias                       = "us-east-1"
  access_key                  = "FakeAccessKeyId"
  secret_key                  = "FakeSecretAccessKey"
  skip_get_ec2_platforms      = true
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  region                      = "us-east-1"
}