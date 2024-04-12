#--------------------------------------- Local Variables --------------------------------------------#

locals {
  all_domain_names = var.site_domain_name != null ? concat([var.site_domain_name], var.alternate_domains) : null
}

#--------------------------------------- Inputs to the Module ---------------------------------------#

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to create"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}

variable "site_domain_name" {
  type        = string
  description = "Domain name of website"
  default = null
}

variable "alternate_domains" {
  type        = list(string)
  description = "Alternate domains to add to the ACM certificate"
  default     = []
}

variable "oac_name" {
  type = string
  description = "Name of OAC to connect CloudFront and the S3 Bucket"
  default = "s3_static_site_oac"
}

variable "tls_cert_validated" {
  type = bool
  description = "Set true if the ACM certificate has already been created and validated (this will create the CloudFront Distribution)"
  default = false
}


#----------------------------------- Outputs from the Module ---------------------------------------#

output "bucket_name" {
  value = aws_s3_bucket.site_build.id
}

output "distribution_name" {
  value = var.tls_cert_validated == true ? aws_cloudfront_distribution.s3_distribution[0].domain_name : "none created"
}
