output "arn" {
  value = aws_lambda_function.this.arn
}

output "url" {
  value = aws_lambda_function_url.this.function_url
}