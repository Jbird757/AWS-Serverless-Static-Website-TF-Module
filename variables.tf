#--------------------------------------- Module Inputs ---------------------------------------#

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to create for static website hosting"
}

variable "force_destroy" {
  type        = bool
  description = "Whether to allow Terraform to destroy the S3 bucket even if it contains objects"
  default     = false
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all created resources"
  default     = {}
}

variable "site_domain_name" {
  type        = string
  description = "Primary domain name for the website (e.g. example.com)"
  default     = null
}

variable "alternate_domains" {
  type        = list(string)
  description = "Alternate domain names (SANs) to add to the ACM certificate and CloudFront aliases"
  default     = []
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of a pre-existing, validated ACM certificate. If provided, certificate creation inside the module is bypassed."
  default     = null
}

variable "oac_name" {
  type        = string
  description = "Name of the CloudFront Origin Access Control (OAC)"
  default     = "s3_static_site_oac"
}

variable "default_root_object" {
  type        = string
  description = "Default object to serve when visiting the root domain"
  default     = "index.html"
}

variable "price_class" {
  type        = string
  description = "CloudFront price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  default     = "PriceClass_100"
}

variable "geo_restriction_type" {
  type        = string
  description = "Method to restrict distribution of content by country (none, whitelist, blacklist)"
  default     = "none"
}

variable "geo_restriction_locations" {
  type        = list(string)
  description = "ISO 3166-1-alpha-2 country codes for geo restriction"
  default     = []
}

variable "cache_policy_id" {
  type        = string
  description = "CloudFront Cache Policy ID to use for default cache behavior. Defaults to AWS Managed-CachingOptimized via data source."
  default     = null
}

variable "enable_security_headers" {
  type        = bool
  description = "Whether to attach standard Security Headers (HSTS, Frame-Options, Content-Type-Options, Referrer-Policy, XSS-Protection)"
  default     = true
}

variable "response_headers_policy_id" {
  type        = string
  description = "Custom CloudFront Response Headers Policy ID to attach. Overrides enable_security_headers if specified."
  default     = null
}
