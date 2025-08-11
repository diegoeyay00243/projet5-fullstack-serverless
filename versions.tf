terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "tfstate-projet5-prod"   # Mon bucket CI/CD
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
}
