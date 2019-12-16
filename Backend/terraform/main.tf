provider "aws" {
  region = "us-east-1"
  profile = "name_of_your_local_aws_profile"

  version = "~> 2.33"
}

locals {
  dynamo_table_name           = "PrismApiTable"
  dynamodb_tables_count       = 1
  dynamodb_policy_action_list = ["dynamodb:*"]

  lambda_code_bucket_name     = "<<<name-of-s3-bucket-you-created>>>" # This must be created manually beforehand
  api_lambda_function_name    = "Prism-Api-Lambda"
  auth_lambda_function_name   = "Prism-Auth-Lambda"
  root-domain                 = "<<<my-route53-domain.com>>>" # Must be created manually in AWS console

  hub_authorization_url       = "<<<https://authorization.ehr.com>>>" # URL of Smart on FHIR identify server
  hub_public_key_fingerprint  = "<<<fingerprint_of_auth_server_key>>>" # Thumbprint from AWS Identity Provider

  # These are any authorized client ids you get from your SMART on FHIR IDP.
  hub_client_ids              = [
    "<<<get_me_from_SMART_on_FHIR_client_1>>>",
  ]
}

# These are defined in secrets.auto.tfvars
variable "promis_api_username" { }
variable "promis_api_password" { }
variable "auth_s3_key" { }
variable "api_s3_key" { }

output "PrismRubyUrl" { value = "${module.Prism-Ruby-API-Gateway.base_url}" }
output "PrismAuthUrl" { value = "${module.Prism-Auth-API-Gateway.base_url}" }

module "dynamoDb" {
  source = "./dynamodb"

  table_name = local.dynamo_table_name
}

# Role and permission for BOTH lambda functions
module "lambda_role_and_perm" {
  source = "./iam"

  #Setup
  # lambda_name                 = "${local.api_lambda_function_name}"
  dynamodb_arn                = "${module.dynamoDb.dynamodb_table_arn}"
  dynamodb_policy_action_list = "${local.dynamodb_policy_action_list}"
  dynamodb_tables_count       = "${local.dynamodb_tables_count}"
  api_lambda_name             = "${local.api_lambda_function_name}"
}

# API Lambda
module "ApiLambda" {
  source = "./lambda"

  function_name = local.api_lambda_function_name
  s3_key        = "${var.api_s3_key}"
  s3_bucket     = "${local.lambda_code_bucket_name}"
  handler       = "lambda.handler"
  runtime       = "ruby2.5"
  memory_size   = 512

  # lambda_exec_role_arn = aws_iam_role.lambda_exec.arn
  lambda_exec_role_arn = module.lambda_role_and_perm.lambda_role_arn

  environment_variables = {
    DYNAMO_TABLE_NAME   = local.dynamo_table_name
    HUB_FHIR_URL        = "https://fhir.prismformedstar.net"
    PROMIS_API_USERNAME = "${var.promis_api_username}"
    PROMIS_API_PASSWORD = "${var.promis_api_password}"
    RACK_ENV            = "production"
    FUNCTION_NAME       = local.api_lambda_function_name
    ASYNC_ARCHIVE       = "true"
  }
}

module "Prism-Ruby-API-Gateway" {
  source = "./ruby_api_gateway"

  lambda_invoke_arn = "${module.ApiLambda.lambda_invoke_arn}"
  lambda_arn        = "${module.ApiLambda.lambda_arn}"
  root-domain       = local.root-domain
}

# Auth Lambda
module "AuthLambda" {
  source = "./lambda"

  function_name = local.auth_lambda_function_name
  s3_key        = "${var.auth_s3_key}"
  s3_bucket     = "${local.lambda_code_bucket_name}"
  handler       = "lambda.handler"
  runtime       = "nodejs10.x"
  memory_size   = 1024

  # lambda_exec_role_arn = aws_iam_role.lambda_exec.arn
  lambda_exec_role_arn = module.lambda_role_and_perm.lambda_role_arn

  environment_variables = {
    DYNAMO_TABLE_NAME = local.dynamo_table_name
    NODE_ENV = "production"
  }
}

# Auth API Gateway
module "Prism-Auth-API-Gateway" {
  source = "./auth_api_gateway"

  lambda_invoke_arn = "${module.AuthLambda.lambda_invoke_arn}"
  lambda_arn        = "${module.AuthLambda.lambda_arn}"
  root-domain       = local.root-domain
}

# NOTE!!!!! After launch, NEVER remove this block. That will
# destroy the identity pool which will result in corrupted data
# and users loosing their data
module "Prism-Cognito" {
  source = "./cognito"

  identity_provider_arn = aws_iam_openid_connect_provider.test.arn
  ruby_api_arn          = module.Prism-Ruby-API-Gateway.api_arn
  auth_api_arn          = module.Prism-Auth-API-Gateway.api_arn
}

# OpenID Connect Identity Provider.
# CHANGE AFTER HUB TERRAFORM IS DONE
#
# Requires:
#   1) Authorization URL
#   2) Client ID(s). This will be the uuid of the doorkeeper application
resource "aws_iam_openid_connect_provider" "test" {
  url             = local.hub_authorization_url
  client_id_list  = local.hub_client_ids
  thumbprint_list = [local.hub_public_key_fingerprint]
}
