#--------------------------------------- Local Variables --------------------------------------------#

locals {
  all_domain_names           = var.site_domain_name != null ? concat([var.site_domain_name], var.alternate_domains) : null
  certificate_arn            = var.acm_certificate_arn != null ? var.acm_certificate_arn : (var.site_domain_name != null ? aws_acm_certificate.site_tls_cert[0].arn : null)
  response_headers_policy_id = var.response_headers_policy_id != null ? var.response_headers_policy_id : (var.enable_security_headers ? aws_cloudfront_response_headers_policy.security_headers[0].id : null)
  cache_policy_id            = var.cache_policy_id != null ? var.cache_policy_id : data.aws_cloudfront_cache_policy.caching_optimized[0].id
}
