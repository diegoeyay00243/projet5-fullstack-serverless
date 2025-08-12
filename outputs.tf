########################################
# 🌍 S3 Static Website (multi-région)
########################################

output "site_us_url" {
  description = "URL du site hébergé en us-east-1 (via S3)"
  value       = "http://${aws_s3_bucket.site_us.bucket}.s3-website-us-east-1.amazonaws.com"
}

output "site_eu_url" {
  description = "URL du site hébergé en eu-west-1 (via S3)"
  value       = "http://${aws_s3_bucket.site_eu.bucket}.s3-website-eu-west-1.amazonaws.com"
}

########################################
# 🌐 CloudFront
########################################

output "cloudfront_url" {
  description = "URL publique CloudFront (HTTPS)"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

output "custom_domain" {
  description = "URL via domaine personnalisé (ex: hkh24.xyz)"
  value       = "https://hkh24.xyz"
}

########################################
# 🧠 Lambda
########################################

output "lambda_function_name" {
  description = "Nom de la fonction lambda"
  value       = module.lambda.function_name
}


########################################
# 🌐 API Gateway
########################################

output "api_gateway_url" {
  description = "URL publique de l’API REST pour le formulaire contact"
  value       = "https://${module.api.contact_api_id}.execute-api.us-east-1.amazonaws.com/prod/contact"
}


########################################
# 🗃️ DynamoDB
########################################

output "dynamodb_table_name" {
  description = "Nom de la table DynamoDB"
  value       = module.dynamodb.dynamodb_table_name
}

########################################
# ☁️ Réseau VPC
########################################

output "vpc_id" {
  description = "ID du VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID du subnet public"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID du subnet privé"
  value       = module.vpc.private_subnet_id
}
