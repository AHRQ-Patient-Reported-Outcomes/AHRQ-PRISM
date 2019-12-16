variable "rest_api_id" {
  type = "string"
}

variable "resource_id" {
  type = "string"
}

variable "authorization" {
  type = "string"
  default = "AWS_IAM"
}

variable "http_method" {
  type = "string"
}

variable "lambda_invoke_arn" {
  type = "string"
}

variable "lambda_arn" {
  type = "string"
}

variable "request_parameters" {
  type = "map"
  default = {}
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${var.resource_id}"
  http_method   = "${var.http_method}"
  authorization = "${var.authorization}"
  request_parameters      = var.request_parameters
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_method.this.resource_id}"
  http_method = "${aws_api_gateway_method.this.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_invoke_arn}"
}
