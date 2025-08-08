#!/bin/bash
terraform destroy -var-file=terraform.tfvars -auto-approve
# This script is used to destroy the Terraform-managed infrastructure.