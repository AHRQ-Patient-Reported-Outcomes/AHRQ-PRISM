variable "identity_provider_arn" {
  type = "string"
}

variable "ruby_api_arn" { }
variable "auth_api_arn" { }

# Cognito Identity Pool
# NOTE!!!!! After launch, NEVER remove this block. That will
# destroy the identity pool which will result in corrupted data
# and users loosing their data
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "PRISM Identity Pool"
  allow_unauthenticated_identities = false

  openid_connect_provider_arns = ["${var.identity_provider_arn}"]

  lifecycle {
    prevent_destroy = true
  }
}

# =========================
# UNauthenticate
# =========================
resource "aws_iam_role" "unauthenticated" {
  name = "prism-unauth-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "unauthenticated" {
  name = "prism-unauthenticated-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": "*",
      "Effect": "Deny",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "unauthenticated" {
  role       = "${aws_iam_role.unauthenticated.name}"
  policy_arn = "${aws_iam_policy.unauthenticated.arn}"
}

# =========================
# Authenticated
# =========================
resource "aws_iam_role" "authenticated" {
  name = "prism-authenticated-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "authenticated" {
  name = "prism-authenticated-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }, {
        "Sid": "Manual1",
        "Effect": "Allow",
        "Action": [
            "execute-api:Invoke"
        ],
        "Resource": [
            "${var.ruby_api_arn}/*/*/*",
            "${var.auth_api_arn}/*/*/*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "authenticated" {
  role       = "${aws_iam_role.authenticated.name}"
  policy_arn = "${aws_iam_policy.authenticated.arn}"
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = "${aws_cognito_identity_pool.main.id}"

  # role_mapping {
  #   identity_provider         = "graph.facebook.com"
  #   ambiguous_role_resolution = "AuthenticatedRole"
  #   type                      = "Rules"

  #   mapping_rule {
  #     claim      = "isAdmin"
  #     match_type = "Equals"
  #     role_arn   = "${aws_iam_role.authenticated.arn}"
  #     value      = "paid"
  #   }
  # }

  roles = {
    "authenticated" = "${aws_iam_role.authenticated.arn}"
    "unauthenticated" = "${aws_iam_role.unauthenticated.arn}"
  }
}
