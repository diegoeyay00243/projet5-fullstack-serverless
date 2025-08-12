provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west"
  region = "eu-west-1"
}

###############################
# Modules : VPC, Lambda, API Gateway, DynamoDB
###############################

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "lambda" {
  source               = "./modules/lambda"
  lambda_function_name = "contact_handler"
  lambda_handler       = "index.handler"
  lambda_runtime       = "nodejs18.x"
  lambda_zip_path      = "modules/lambda/lambda.zip"
  dynamodb_table_name  = var.dynamodb_table_name
  email_sender         = "ngamunaeyay2@gmail.com"
  email_password       = "mot_de_passe_app"
  email_receiver       = "ngamunaeyay2@gmail.com"
}

module "api" {
  source            = "./modules/api_gateway"
  api_name          = var.api_name
  lambda_invoke_arn = module.lambda.invoke_arn
}

module "dynamodb" {
  source              = "./modules/dynamodb"
  dynamodb_table_name = var.dynamodb_table_name
}

##############################
# Infos sur le compte AWS
##############################

data "aws_caller_identity" "current" {}

##############################
# Buckets S3 (US et EU)
##############################

resource "aws_s3_bucket" "site_us" {
  provider      = aws.us_east
  bucket        = "mon-site-multiregion-us"
  force_destroy = true
}

resource "aws_s3_bucket" "site_eu" {
  provider      = aws.eu_west
  bucket        = "mon-site-multiregion-eu"
  force_destroy = true
}

resource "aws_s3_bucket" "logs" {
  bucket = "mon-site-logs-bucket"
  tags = {
    Name = "Logs Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "logs_block" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = false # ✅ CloudFront doit pouvoir écrire
  block_public_policy     = true
  ignore_public_acls      = false # ✅ Important aussi
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "logs_ownership" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_ownership]
  bucket     = aws_s3_bucket.logs.id
  acl        = "log-delivery-write"
}

##############################
# Configuration statique des sites
##############################

resource "aws_s3_bucket_website_configuration" "website_us" {
  provider = aws.us_east
  bucket   = aws_s3_bucket.site_us.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_website_configuration" "website_eu" {
  provider = aws.eu_west
  bucket   = aws_s3_bucket.site_eu.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_object" "index_us" {
  provider     = aws.us_east
  bucket       = aws_s3_bucket.site_us.id
  key          = "index.html"
  source       = "${path.module}/site/index.html"
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_bucket_object" "error_us" {
  provider     = aws.us_east
  bucket       = aws_s3_bucket.site_us.id
  key          = "error.html"
  source       = "${path.module}/site/error.html"
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_bucket_object" "index_eu" {
  provider     = aws.eu_west
  bucket       = aws_s3_bucket.site_eu.id
  key          = "index.html"
  source       = "${path.module}/site/index.html"
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_bucket_object" "error_eu" {
  provider     = aws.eu_west
  bucket       = aws_s3_bucket.site_eu.id
  key          = "error.html"
  source       = "${path.module}/site/error.html"
  content_type = "text/html; charset=utf-8"
}


resource "aws_s3_bucket_policy" "site_us_policy" {
  bucket = aws_s3_bucket.site_us.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.site_us.arn}/*"
      },
      {
        Sid    = "CloudFrontAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.site_us.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.site_us_block]
}


resource "aws_s3_bucket_policy" "site_eu_policy" {
  provider = aws.eu_west
  bucket   = aws_s3_bucket.site_eu.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.site_eu.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.site_eu_block]
}

resource "aws_s3_bucket_public_access_block" "site_us_block" {
  provider                = aws.us_east
  bucket                  = aws_s3_bucket.site_us.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "site_eu_block" {
  provider                = aws.eu_west
  bucket                  = aws_s3_bucket.site_eu.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

##############################
# CloudFront
##############################

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for CloudFront to access S3 bucket"
}


resource "aws_cloudfront_distribution" "cdn" {
  # aliases = ["hkh24.xyz"]

  origin {
    domain_name = aws_s3_bucket.site_us.bucket_regional_domain_name
    origin_id   = "s3-site-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-site-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:728182301123:certificate/a4672fda-ac9b-4ac2-a726-26317cfe7c49"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  logging_config {
    bucket          = "${aws_s3_bucket.logs.bucket}.s3.amazonaws.com"
    include_cookies = false
    prefix          = "cf-logs/"
  }


  tags = {
    Name = "StaticSiteDistribution"
  }
}

resource "aws_s3_bucket_policy" "logs_policy" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPutLogs",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.logs.arn}/cf-logs/*",
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowGetBucketAcl",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = "${aws_s3_bucket.logs.arn}"
      }
    ]
  })
}

##############################
# lambda
##############################

# Vérifie que Lambda autorise bien API Gateway à l’invoquer

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke-${module.api.contact_api_id}"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.execution_arn}/*/*"
}

