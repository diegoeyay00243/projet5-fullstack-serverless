output "contact_api_id" {
  description = "ID de l'API Gateway"
  value       = aws_api_gateway_rest_api.contact_api.id
}

output "contact_api_root_resource_id" {
  description = "ID de la ressource racine"
  value       = aws_api_gateway_rest_api.contact_api.root_resource_id
}

output "contact_resource_id" {
  description = "ID de la ressource /contact"
  value       = aws_api_gateway_resource.contact.id
}


output "execution_arn" {
  description = "ARN d'exécution de l'API Gateway"
  value       = aws_api_gateway_rest_api.contact_api.execution_arn
}

