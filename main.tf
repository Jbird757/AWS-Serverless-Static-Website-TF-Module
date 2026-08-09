#------------------------------------------------ S3 Storage ------------------------------------------------#

resource "aws_s3_bucket" "site_build" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "site_build" {
  bucket                  = aws_s3_bucket.site_build.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site_build" {
  bucket = aws_s3_bucket.site_build.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.site_build.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.site_build.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

#------------------------------------------------ CloudFront Cache Policy Data Source ------------------------------------------------#

data "aws_cloudfront_cache_policy" "caching_optimized" {
  count = var.cache_policy_id == null ? 1 : 0
  name  = "Managed-CachingOptimized"
}

#------------------------------------------------ Security Headers Policy ------------------------------------------------#

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  count = var.enable_security_headers && var.response_headers_policy_id == null ? 1 : 0
  name  = "${var.bucket_name}-security-headers"

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    xss_protection {
      mode_block = true
      override   = true
      protection = true
    }
  }
}

#------------------------------------------------ CloudFront Distribution ------------------------------------------------#

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = var.oac_name
  description                       = "OAC to connect s3_distribution with S3 bucket ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.site_build.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id                = "S3-${aws_s3_bucket.site_build.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object

  aliases = local.all_domain_names

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "S3-${aws_s3_bucket.site_build.id}"
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = local.cache_policy_id
    response_headers_policy_id = local.response_headers_policy_id
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/${var.default_root_object}"
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  tags = var.common_tags

  viewer_certificate {
    acm_certificate_arn            = local.certificate_arn
    cloudfront_default_certificate = local.certificate_arn == null ? true : false
    ssl_support_method             = local.certificate_arn != null ? "sni-only" : null
    minimum_protocol_version       = local.certificate_arn != null ? "TLSv1.2_2021" : "TLSv1"
  }
}

#------------------------------------------------ ACM Certificate ------------------------------------------------#

resource "aws_acm_certificate" "site_tls_cert" {
  count                     = var.site_domain_name != null && var.acm_certificate_arn == null ? 1 : 0
  domain_name               = var.site_domain_name
  subject_alternative_names = var.alternate_domains
  validation_method         = "DNS"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}
