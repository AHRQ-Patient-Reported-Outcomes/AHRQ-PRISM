output "dynamodb_table_name" {
  value = aws_dynamodb_table.prism-db.name
}

output "dynamodb_table_hash_key" {
  value = aws_dynamodb_table.prism-db.hash_key
}

output "dynamodb_table_range_key" {
  value = aws_dynamodb_table.prism-db.range_key
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.prism-db.arn
}

output "dynamodb_table_stream_arn" {
  value = aws_dynamodb_table.prism-db.stream_arn
}
