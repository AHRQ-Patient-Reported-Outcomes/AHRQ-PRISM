variable "rest_api_id" {
  type = "string"
}

variable "root_resource_id" {
  type = "string"
}

variable "path_part" {
  type = "string"
}

variable "has_options" {
  type = "boolean"
  default = true
}

output "resource_id" {
  value = "${aws_api_gateway_resource.this.id}"
}

# The Resource. Aka "/token"
resource "aws_api_gateway_resource" "this" {
  rest_api_id = "${var.rest_api_id}"
  parent_id   = "${var.root_resource_id}"
  path_part   = "${var.path_part}"
}

# Method on Resource. GET, POST, PUT, OPTIONS
# This appears in the console as "Method Request"
resource "aws_api_gateway_method" "this-options" {
  count         = var.has_options ? 1 : 0
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${aws_api_gateway_resource.this.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Console: "Integration Request"
# This is what I need to fix
resource "aws_api_gateway_integration" "this-options" {
  count       = var.has_options ? 1 : 0
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.this.id}"
  http_method = "OPTIONS"
  type        = "MOCK"

  depends_on = ["aws_api_gateway_resource.this"]

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# Console: "Integration Response"
resource "aws_api_gateway_integration_response" "this-options" {
  count       = var.has_options ? 1 : 0
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.this.id}"
  http_method = "${aws_api_gateway_method.this-options[0].http_method}"
  status_code   = 200

  response_parameters = "${local.integration_response_parameters}"

  depends_on = [
    "aws_api_gateway_integration.this-options[0]",
    "aws_api_gateway_method_response.this-options[0]",
  ]
}

resource "aws_api_gateway_method_response" "this-options" {
    count       = var.has_options ? 1 : 0
    rest_api_id = "${var.rest_api_id}"
    resource_id = "${aws_api_gateway_resource.this.id}"
    http_method = "${aws_api_gateway_method.this-options[0].http_method}"
    status_code = 200

    response_models = { "application/json" = "Empty" }
    response_parameters = "${local.method_response_parameters}"

    depends_on = ["aws_api_gateway_method.this-options[0]"]
}
