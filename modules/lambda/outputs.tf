output "function_name" {
  description = "Nom de la fonction Lambda"
  value       = aws_lambda_function.contact.function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda"
  value       = aws_lambda_function.contact.arn
}

output "invoke_arn" {
  description = "Invoke ARN de la fonction Lambda"
  value       = aws_lambda_function.contact.invoke_arn
}


