variable "function_name" {
  type = "string"
  description = "Name of the Lambda Function"
}

variable "s3_key" {
  type = "string"
  description = "Name of the file in S3"
}

variable "s3_bucket" {
  type = "string"
  description = "Name of the S3 bucket"
}

variable "handler" {
  type = "string"
  description = "lambda handler"
}

variable "runtime" {
  type = "string"
  description = "Runtime env of lamda. Ruby, Node ..."
}

variable "memory_size" {
  type = "string"
  description = "Memory in MB for lambda"
}

variable "lambda_exec_role_arn" {
  type = "string"
  description = "ARN of lambda exec role"
}

variable "environment_variables" {
  type = "map"
  description = "lambda env vars"
}
