variable "lambda_function_name" {}
variable "lambda_handler" {}
variable "lambda_runtime" {}
variable "lambda_zip_path" {}
variable "dynamodb_table_name" {}

variable "email_sender" {
  description = "Adresse de l'expéditeur"
  type        = string
}

variable "email_password" {
  description = "Mot de passe SMTP ou App password"
  type        = string
}

variable "email_receiver" {
  description = "Adresse e-mail destinataire"
  type        = string
}

