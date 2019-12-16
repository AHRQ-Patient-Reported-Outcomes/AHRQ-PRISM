resource "aws_dynamodb_table" "prism-db" {
  name           = "${var.table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "primaryKey"
  range_key      = "sortKey"

  attribute {
    name = "primaryKey"
    type = "S"
  }

  attribute {
    name = "sortKey"
    type = "S"
  }

  attribute {
    name = "GSI_1_PK"
    type = "S"
  }

  attribute {
    name = "GSI_1_SK"
    type = "S"
  }

  attribute {
    name = "GSI_2_PK"
    type = "S"
  }

  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

  global_secondary_index {
    name               = "inProgressQuestionnaireResponses"
    hash_key           = "GSI_2_PK"
    range_key          = "primaryKey"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
    # non_key_attributes = ["UserId"]
  }

  global_secondary_index {
    name               = "GSI-1"
    hash_key           = "GSI_1_PK"
    range_key          = "GSI_1_SK"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
    # non_key_attributes = ["UserId"]
  }

  tags = {
    Name        = "Prism-Dynamo"
    Project     = "Prism"
  }
}
