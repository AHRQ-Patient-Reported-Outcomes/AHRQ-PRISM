# =============== #
# Create the Role #
# =============== #
resource "aws_iam_role" "lambda-role" {
  name = "PrismLambda-Role"
  assume_role_policy = "${file("${path.module}/lambda-role.json")}"
}

# ============================================= #
# Create and Attach custom policies to the Role #
# ============================================= #
data "template_file" "lambda_dynamodb_policy" {
  template = "${file("${path.module}/dynamodb-policy.json")}"
  vars = {
    policy_arn_list = "${var.dynamodb_arn}"
    policy_action_list = "${join(", ", formatlist("\"%s\"", var.dynamodb_policy_action_list))}"
  }
}

resource "aws_iam_role_policy" "DynamoDB-Policy" {
  name = "${aws_iam_role.lambda-role.name}-Policy"
  role = "${aws_iam_role.lambda-role.id}"
  policy = "${data.template_file.lambda_dynamodb_policy.rendered}"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "template_file" "invoke_api_lambda_policy" {
  template = "${file("${path.module}/async-invoke-api-lambda-policy.json")}"

  vars = {
    aws_region      = data.aws_region.current.name
    account_id      = data.aws_caller_identity.current.account_id
    api_lambda_name = var.api_lambda_name
  }
}

resource "aws_iam_role_policy" "Invoke-API-Lambda-Async" {
  name = "${aws_iam_role.lambda-role.name}-Async-Lambda-Policy"
  role = "${aws_iam_role.lambda-role.id}"
  policy = "${data.template_file.invoke_api_lambda_policy.rendered}"
}

# ======================================= #
# Attach AWS Managed Policies to the role #
# ======================================= #
resource "aws_iam_role_policy_attachment" "Lambda-CloudWatch-Logs-ReadWrite" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role = "${aws_iam_role.lambda-role.name}"
}

