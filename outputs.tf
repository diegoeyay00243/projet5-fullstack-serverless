# URL S3 directes (comme dans Projet 3)
output "site_us_url" {
  description = "URL du site hébergé en us-east-1 (via S3)"
  value       = "http://${aws_s3_bucket.site_us.bucket}.s3-website-us-east-1.amazonaws.com"
}

output "site_eu_url" {
  description = "URL du site hébergé en eu-west-1 (via S3)"
  value       = "http://${aws_s3_bucket.site_eu.bucket}.s3-website-eu-west-1.amazonaws.com"
}

# URL de la distribution CloudFront
output "cloudfront_url" {
  description = "URL de la distribution CloudFront (HTTPS)"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

# (Optionnel) Domaine personnalisé si hkh24.xyz est relié via Route 53
# Décommente quand ton domaine est bien connecté à CloudFront
 output "custom_domain" {
   description = "URL du site via le domaine personnalisé"
   value       = "https://hkh24.xyz"
 }

# (Optionnel) Pour debug du certificat (si tu avais laissé le cert ACM dans le code)
# output "cert_validation_records" {
#   value = aws_acm_certificate.cert.domain_validation_options
# }
