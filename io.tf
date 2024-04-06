#--------------------------------------- Local Variables --------------------------------------------#

locals {
  all_domain_names = concat([var.site_domain_name], var.alternate_domains)
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
}

variable "alternate_domains" {
  type        = list(string)
  description = "Alternate domains to add to the ACM certificate"
  default     = []
}

#----------------------------------- Outputs from the Module ---------------------------------------#

output "bucket_name" {
  value = aws_s3_bucket.site_build.id
}

output "distribution_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}