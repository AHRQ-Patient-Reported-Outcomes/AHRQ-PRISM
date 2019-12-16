# variable "lambda_name" {
#   description = "The name of the Lambda function"
# }

variable "dynamodb_arn" {
  type = "string"
  description = "ARN's to allow permissions for"
}

variable "dynamodb_policy_action_list" {
  type = "list"
  description = "List of ARN's to allow permissions for"
}

variable "dynamodb_tables_count" {
  description = "Number of tables being created"
}

variable "api_lambda_name" {
  description = "Name of the API Lambda"
}
