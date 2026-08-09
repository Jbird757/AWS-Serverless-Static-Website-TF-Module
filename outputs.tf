#----------------------------------- Module Outputs ---------------------------------------#

output "bucket_name" {
  description = "Name (ID) of the created S3 bucket"
  value       = aws_s3_bucket.site_build.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.site_build.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the created S3 bucket"
  value       = aws_s3_bucket.site_build.bucket_regional_domain_name
}

output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.arn
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate created or passed in"
  value       = local.certificate_arn
}

output "domain_validation_options" {
  description = "List of domain validation options for DNS validation if an ACM certificate was created"
  value       = var.site_domain_name != null && var.acm_certificate_arn == null ? aws_acm_certificate.site_tls_cert[0].domain_validation_options : []
}

output "response_headers_policy_id" {
  description = "ID of the CloudFront Response Headers Policy applied to the distribution"
  value       = local.response_headers_policy_id
}
