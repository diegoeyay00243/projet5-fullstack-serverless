########################################
# 🌍 Buckets S3 & Certificat
########################################

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

########################################
# ☁️ VPC & Réseau
########################################

variable "vpc_cidr_block" {
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR du subnet public"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR du subnet privé"
  type        = string
  default     = "10.0.2.0/24"
}

########################################
# 🧠 Lambda (traitement du formulaire)
########################################

variable "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
  default     = "submitContactForm"
}

variable "lambda_handler" {
  description = "Nom du handler Lambda"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Runtime de la Lambda"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_zip_path" {
  description = "Chemin du fichier .zip pour Lambda"
  type        = string
}

# Email vars (optionnel si transmis directement dans le module)
variable "email_sender" {
  description = "Adresse e-mail expéditrice (utilisateur SMTP)"
  type        = string
}

variable "email_password" {
  description = "Mot de passe SMTP ou App password"
  type        = string
}

variable "email_receiver" {
  description = "Adresse e-mail de réception"
  type        = string
}

########################################
# 🌐 API Gateway
########################################

variable "api_name" {
  description = "Nom de l'API Gateway"
  type        = string
  default     = "api-contact-hkh24"
}

########################################
# 🗃️ DynamoDB
########################################

variable "dynamodb_table_name" {
  description = "Nom de la table DynamoDB"
  type        = string
  default     = "messages"
}