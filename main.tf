#------------------------------------------------ S3 Endpoint ------------------------------------------------#

resource "aws_s3_bucket" "site_build" {
  bucket = var.bucket_name
  force_destroy = true
  tags = var.common_tags
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" { #Bucket Policy Object, which contains an IAM policy (below)
  bucket = aws_s3_bucket.site_build.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" { #IAM Policy Object to populate the S3 Bucket Policy
  depends_on = [aws_cloudfront_distribution.s3_distribution]

  statement {
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.site_build.arn}/*"
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = ["${aws_cloudfront_distribution.s3_distribution.arn}"]
    }
  }
}

#------------------------------------------------ CloudFront Distribution ------------------------------------------------#

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_s3_bucket.site_build, aws_acm_certificate.site_tls_cert]

  origin {
    domain_name              = aws_s3_bucket.site_build.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id                = aws_s3_bucket.site_build.bucket_regional_domain_name
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = local.all_domain_names

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.site_build.bucket_regional_domain_name

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_code = 403
    response_code = 200
    response_page_path = "/index.html"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "JP"]
    }
  }

  tags = var.common_tags

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.site_tls_cert.arn
    ssl_support_method = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "s3_oac" { #CloudFront OAC
  name                              = "s3_oac"
  description                       = "OAC to connect s3_distribution with the S3 bucket site_build"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#------------------------------------------------ ACM Certificate ------------------------------------------------#

resource "aws_acm_certificate" "site_tls_cert" {
  domain_name               = var.site_domain_name
  subject_alternative_names = var.alternate_domains
  validation_method         = "DNS"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}
