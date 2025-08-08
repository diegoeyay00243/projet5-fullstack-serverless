#!/bin/bash
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars -auto-approve
# This script is used to deploy the Terraform-managed infrastructure.
# It initializes Terraform, plans the deployment, and applies the changes automatically.