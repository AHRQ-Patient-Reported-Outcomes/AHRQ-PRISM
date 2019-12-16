# variable "app_version" {
# }

# https://github.com/techjacker/terraform-aws-lambda-api-gateway/blob/master/main.tf

resource "aws_lambda_function" "api_lambda" {
  function_name = "${var.function_name}"

  s3_bucket   = "${var.s3_bucket}"
  s3_key      = "${var.s3_key}"
  handler     = "${var.handler}"
  runtime     = "${var.runtime}"
  memory_size = "${var.memory_size}"
  role        = "${var.lambda_exec_role_arn}"
  timeout     = 30

  environment {
    variables = var.environment_variables
  }

  tags = {
    Name        = "${var.function_name}"
    Project     = "Prism"
  }
}
