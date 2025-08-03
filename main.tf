provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west"
  region = "eu-west-1"
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

##############################
# Bucket S3 pour les logs CloudFront
##############################

resource "aws_s3_bucket" "logs" {
  provider      = aws.us_east
  bucket        = "mon-site-logs-bucket"
  force_destroy = true
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

##############################
# Upload des fichiers dans S3
##############################

resource "aws_s3_bucket_object" "index_us" {
  provider     = aws.us_east
  bucket       = aws_s3_bucket.site_us.id
  key          = "index.html"
  source       = "${path.module}/site/index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error_us" {
  provider     = aws.us_east
  bucket       = aws_s3_bucket.site_us.id
  key          = "error.html"
  source       = "${path.module}/site/error.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "index_eu" {
  provider     = aws.eu_west
  bucket       = aws_s3_bucket.site_eu.id
  key          = "index.html"
  source       = "${path.module}/site/index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error_eu" {
  provider     = aws.eu_west
  bucket       = aws_s3_bucket.site_eu.id
  key          = "error.html"
  source       = "${path.module}/site/error.html"
  content_type = "text/html"
}

##############################
# CloudFront OAI (Origin Access Identity)
##############################

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for CloudFront to access S3 bucket"
}

##############################
# S3 Policy pour autoriser OAI à lire le bucket S3
##############################

resource "aws_s3_bucket_policy" "cf_s3_policy" {
  provider = aws.us_east
  bucket   = aws_s3_bucket.site_us.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.site_us.arn}/*"
      }
    ]
  })
}

##############################
# CloudFront avec SSL et hkh24.xyz
##############################

resource "aws_cloudfront_distribution" "cdn" {
  aliases = ["hkh24.xyz"] # domaine personnalisé

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
  acm_certificate_arn = "arn:aws:acm:us-east-1:728182301123:certificate/a4672fda-ac9b-4ac2-a726-26317cfe7c49"
  ssl_support_method = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
}


  logging_config {
    bucket          = aws_s3_bucket.logs.bucket_regional_domain_name
    include_cookies = false
    prefix          = "cf-logs/"
  }

  tags = {
    Name = "StaticSiteDistribution"
  }
}

##############################
# Policy pour autoriser CloudFront à écrire les logs dans le bucket
##############################

resource "aws_s3_bucket_policy" "logs_policy" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPutLogs",
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.logs.arn}/cf-logs/*",
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "AllowGetBucketAcl",
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action    = "s3:GetBucketAcl",
        Resource  = "${aws_s3_bucket.logs.arn}"
      }
    ]
  })
}
