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
  domain_name              = "api-lambda.${var.root-domain}"
  regional_certificate_arn = "${data.aws_acm_certificate.this.arn}"

  endpoint_configuration { types = ["REGIONAL"] }
}

data "aws_route53_zone" "this" { name = "${var.root-domain}" }
resource "aws_route53_record" "auth-server" {
  name    = "api-lambda.${var.root-domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.id

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.this.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.this.regional_zone_id}"
  }
}

# ===========================
# API Setup
# ===========================
resource "aws_api_gateway_rest_api" "this" {
  name        = "Prism-Ruby-APIGW"
  description = "API Gateway for PRISM Ruby Lambda"
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

# ===========================
# Resources & Methods
# ===========================
module "Patients" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part        = "Patients"
  has_options      = false
}

module "Patients-Current" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${module.Patients.resource_id}"
  path_part        = "current"
}

module "Patients-Current-get" {
  source = "../lambda-endpoint"

  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.Patients-Current.resource_id}"
  http_method        = "GET"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

# ===========================
# QuestionnaireResponses
# ===========================
module "QuestionnaireResponses" {
  source = "../api_resource"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part = "QuestionnaireResponses"
}

module "QuestionnaireResponses-get" {
  source = "../lambda-endpoint"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${module.QuestionnaireResponses.resource_id}"
  http_method = "GET"
  lambda_invoke_arn = "${var.lambda_invoke_arn}"
  lambda_arn = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

module "QuestResp-Id" {
  source = "../api_resource"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${module.QuestionnaireResponses.resource_id}"
  path_part = "{questionnaireResponseId}"
}

module "QuestResp-Id-get" {
  source = "../lambda-endpoint"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${module.QuestResp-Id.resource_id}"
  http_method = "GET"
  lambda_invoke_arn = "${var.lambda_invoke_arn}"
  lambda_arn = "${var.lambda_arn}"
}

module "QuestResp-Id-Next-Q" {
  source = "../api_resource"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${module.QuestResp-Id.resource_id}"
  path_part = "next-q"
}

module "QuestResp-Id-Next-Q-get" {
  source = "../lambda-endpoint"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${module.QuestResp-Id-Next-Q.resource_id}"
  http_method = "GET"
  lambda_invoke_arn = "${var.lambda_invoke_arn}"
  lambda_arn = "${var.lambda_arn}"
}

module "QuestResp-Id-Next-Q-post" {
  source = "../lambda-endpoint"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${module.QuestResp-Id-Next-Q.resource_id}"
  http_method = "POST"
  lambda_invoke_arn = "${var.lambda_invoke_arn}"
  lambda_arn = "${var.lambda_arn}"
}

module "QuestResp-Id-Reset" {
  source = "../api_resource"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${module.QuestResp-Id.resource_id}"
  path_part = "reset"
}

module "QuestResp-Id-Reset-get" {
  source = "../lambda-endpoint"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${module.QuestResp-Id-Reset.resource_id}"
  http_method = "GET"
  lambda_invoke_arn = "${var.lambda_invoke_arn}"
  lambda_arn = "${var.lambda_arn}"
}

module "QuestResp-Id-Result" {
  source = "../api_resource"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${module.QuestResp-Id.resource_id}"
  path_part = "result"
}

module "QuestResp-Id-Result-get" {
  source = "../lambda-endpoint"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${module.QuestResp-Id-Result.resource_id}"
  http_method = "GET"
  lambda_invoke_arn = "${var.lambda_invoke_arn}"
  lambda_arn = "${var.lambda_arn}"
}

# ===========================
# Questionnaires
# ===========================
module "Questionnaires" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part        = "Questionnaires"
  has_options      = false
}

module "Questionnaires-Id" {
  source = "../api_resource"

  rest_api_id      = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${module.Questionnaires.resource_id}"
  path_part        = "{questionnaireId}"
  has_options      = false
}

module "Questionnaires-Id-Result" {
  source = "../api_resource"

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  root_resource_id = "${module.Questionnaires-Id.resource_id}"
  path_part = "results"
}

module "Questionnaires-Id-Result-get" {
  source = "../lambda-endpoint"

  rest_api_id        = "${aws_api_gateway_rest_api.this.id}"
  resource_id        = "${module.Questionnaires-Id-Result.resource_id}"
  http_method        = "GET"
  lambda_invoke_arn  = "${var.lambda_invoke_arn}"
  lambda_arn         = "${var.lambda_arn}"
  request_parameters = {
    "method.request.querystring.status" = true
  }
}

resource "aws_api_gateway_base_path_mapping" "auth-lambda" {
  api_id      = "${aws_api_gateway_rest_api.this.id}"
  stage_name  = "${aws_api_gateway_deployment.this.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.this.domain_name}"
}

# Edit to re-deploy stage
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    "module.Patients-Current-get",
    "module.QuestionnaireResponses-get",
    "module.QuestResp-Id-Reset-get",
    "module.QuestResp-Id-Reset-get",
    "module.QuestResp-Id-Result-get",
    "module.QuestResp-Id-Next-Q-get",
    "module.QuestResp-Id-Next-Q-post",
    "module.Questionnaires-Id-Result-get"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  stage_name  = "Staging"
  stage_description = "${md5(file("${path.module}/main.tf"))}"

  lifecycle {
    create_before_destroy = true
  }
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
