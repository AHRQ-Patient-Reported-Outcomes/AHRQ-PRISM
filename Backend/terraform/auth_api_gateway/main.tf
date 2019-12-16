output "api_arn" {
  value = "${aws_api_gateway_rest_api.this.execution_arn}"
}

# =====================
# Setup Domain name for API
# =====================
data "aws_acm_certificate" "this" {
  domain      = "*.${var.root-domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name              = "auth-lambda.${var.root-domain}"
  regional_certificate_arn = "${data.aws_acm_certificate.this.arn}"

  endpoint_configuration { types = ["REGIONAL"] }
}

data "aws_route53_zone" "this" { name = "${var.root-domain}" }
resource "aws_route53_record" "auth-server" {
  name    = "auth-lambda.${var.root-domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.id

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.this.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.this.regional_zone_id}"
  }
}

# =====================
# API Setup
# =====================
resource "aws_api_gateway_rest_api" "this" {
  name        = "Prism-Auth-APIGW"
  description = "API Gateway for PRISM Auth Lambda"
}

resource "aws_api_gateway_gateway_response" "default_4XX" {
  rest_api_id   = "${aws_api_gateway_rest_api.this.id}"
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_gateway_response" "default_5XX" {
  rest_api_id   = "${aws_api_gateway_rest_api.this.id}"
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
}

# =====================
# Methods and Resources
# =====================

module "callback" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part        = "callback"
}

module "callback-get" {
  source = "../lambda-endpoint"

  authorization      = "NONE"
  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.callback.resource_id}"
  http_method        = "GET"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

module "l" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part        = "l"
}

module "l-get" {
  source = "../lambda-endpoint"

  authorization      = "NONE"
  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.l.resource_id}"
  http_method        = "GET"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

module "launch" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part        = "launch"
}

module "launch-get" {
  source = "../lambda-endpoint"

  authorization      = "NONE"
  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.launch.resource_id}"
  http_method        = "GET"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

module "refresh" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part        = "refresh"
}

module "refresh-get" {
  source = "../lambda-endpoint"

  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.refresh.resource_id}"
  http_method        = "GET"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

module "refresh-post" {
  source = "../lambda-endpoint"

  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.refresh.resource_id}"
  http_method        = "POST"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

module "token" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part        = "token"
}

module "token-get" {
  source = "../lambda-endpoint"

  authorization      = "NONE"
  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.token.resource_id}"
  http_method        = "GET"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

module "token-post" {
  source = "../lambda-endpoint"

  authorization      = "NONE"
  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.token.resource_id}"
  http_method        = "POST"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

# Edit to re-deploy stage
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    "module.callback-get",
    "module.l-get",
    "module.launch-get",
    "module.refresh-get",
    "module.refresh-post",
    "module.token-get",
    "module.token-post",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  stage_name  = "Staging"
  stage_description = "${md5(file("${path.module}/main.tf"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_base_path_mapping" "auth-lambda" {
  api_id      = "${aws_api_gateway_rest_api.this.id}"
  stage_name  = "${aws_api_gateway_deployment.this.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.this.domain_name}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  # source_arn = "${aws_api_gateway_deployment.this.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.this.invoke_url}"
}
