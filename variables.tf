variable "bucket_site_us" {
  description = "Nom du bucket pour la région us-east-1"
  type        = string
  default     = "mon-site-multiregion-us"
}

variable "bucket_site_eu" {
  description = "Nom du bucket pour la région eu-west-1"
  type        = string
  default     = "mon-site-multiregion-eu"
}

variable "bucket_logs" {
  description = "Nom du bucket pour les logs CloudFront"
  type        = string
  default     = "mon-site-logs-bucket"
}

variable "certificate_arn" {
  description = "ARN du certificat SSL ACM pour le domaine personnalisé"
  type        = string
  default     = "arn:aws:acm:us-east-1:728182301123:certificate/1b74582e-9055-4f52-896f-8176af19af41"
}