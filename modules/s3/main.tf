terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  # Add any additional configuration options as needed
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.bucket

  index_document {
    suffix = "index.html"
  }

  # error_document {
  #   key = "index.html"
  # }

}

resource "aws_cloudfront_origin_access_identity" "access" {
  comment = "Allow CloudFront access to S3 bucket"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          AWS : aws_cloudfront_origin_access_identity.access.iam_arn,
        },
        Action : ["s3:GetObject"],
        Resource : ["${aws_s3_bucket.bucket.arn}/*"],
      },
    ],
  })
}

resource "aws_cloudfront_distribution" "this" {

  enabled = true

  origin {
    origin_id   = aws_s3_bucket.bucket.arn
    domain_name = "${var.bucket_name}.s3.${var.region}.amazonaws.com"

    s3_origin_config {

      origin_access_identity = aws_cloudfront_origin_access_identity.access.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {

    target_origin_id = aws_s3_bucket.bucket.arn
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_200"

}
