# AWS Serverless Static Website TF Module

> [!NOTE]
> **AI Assistance Disclaimer**: This Terraform module and documentation were created and modernized with the assistance of AI.

This repository contains a Terraform Module designed to create a static serverless website using AWS S3, CloudFront, and ACM. The intent is to teach and introduce Terraform practices and concepts in a way that also supports best practices for severless hosting. 

Some parts of these instructions are left intentionally vague. This is because these parts include vital skills for using Terraform, and I don't want lazy people (like myself) to skip over these parts and just follow along. 

## Prerequisites

1. A static website - even a simple index.html will do. The root of this site needs to be called index.html if you want to use the default configuration of the module.
2. An AWS account with an IAM user or role set up to allow access to terraform. It will need the following (simplified) permissions:

```
- AmazonS3FullAccess
- AmazonCertificateManagerFullAccess
- CloudFrontFullAccess
```
You will need to have previously signed in with this user on the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) in your local environment. You will also need [Terraform](https://developer.hashicorp.com/terraform/install) installed. After you have installed the utilities, begin the setup process with the `aws configure` command.

3. A domain name - not required, but if you do not have one you will have to access the site via the CloudFront domain, and the ACM certificate will not be used.

## To Begin

Make a new directory (probably called "terraform") in your own website directory. Make a subdirectory in the terraform directory called "modules" and another subdirectory in modules called something descriptive and copy the .tf files to the newest descriptive directory.
- In the terraform directory, create 3 files, called `providers.tf`, `main.tf`, and `variables.tf`.
- In the providers.tf file, copy and paste this code block:


```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

This block sets the version of Terraform and the AWS provider.
Now, in the console in the `terraform/` directory you can run `terraform init` to initialize a terraform project. For the purposes of this module, all Terraform commands should be run in the `terraform` directory. This will set up a backend in this directory that will keep track of changes made. You can also configure the backend to be in an [S3 bucket](https://developer.hashicorp.com/terraform/language/settings/backends/configuration), and for a website hosted on AWS that is probably the better choice. 

## Your Terraform
Look at the `variables.tf` and `outputs.tf` files to view the input variables and outputs of the module. The variables are all inputs to the module. Some are required (those without a `default` attribute). You will need to define these values in your `variables.tf` file and reference them in your `terraform/main.tf` to pass them into the module.

Take note of the `site_domain_name` and `acm_certificate_arn` variables. If you do not have a domain name, leave `site_domain_name = null` (default). If you have a custom domain, pass `site_domain_name = "example.com"`. If you have already validated your ACM certificate outside the module, you can optionally pass `acm_certificate_arn = "arn:aws:acm:..."` to build CloudFront immediately.

Starting in the `variables.tf` file, define and set values for all the local variables (called locals) you want to pass in. See prerequisites for questions about the domain name. [Here](https://developer.hashicorp.com/terraform/language/values/variables) is documentation on making locals. Terraform documentation is quite good.

You will also need to create some other variables, called outputs, that take the output from the module and output it to the console if you want to see the S3 Bucket name and cloudfront distribution domain without needing to log into the AWS console (mostly applicable only if you don't have a domain that you're passing in). 

In the `main.tf` file in the `terraform` directory, reference the module with a module block and pass in the variables. Knowledge on how to do this can also be found in the Terraform Docs. For the source attribute of the module block, use `source = "./modules/{your_descriptive_directory}"`.

Now you can perform the next steps. First run `terraform init` again to initialize the new module. It is always a good idea to validate your code, so run `terraform fmt` and `terraform validate` in the terraform directory. If there are no errors, you can go to the next step, which is to run `terraform plan`. This outputs exactly what Terraform plans to do in your AWS account.

Now is a good time to go over what is actually going on in the Terraform Module. Take a look inside it and get familiar with the different resources which are defined in `resource` blocks in the `main.tf` file.

Once you understand what Terraform will do, run `terraform apply`. This will first do an additional plan, and once you confirm the plan, it will create the resources in AWS.

The apply will take several minutes. Usually it doesn't take this long, but creating a CloudFront Distribution is a slow process. Once it is complete, you can run this command from the directory that contains your index.html file `aws s3 cp {file_name} s3://{Bucket Name}/` to upload your index.html file or run it specifying the directory which holds your static code with the `--recursive` flag for multiple files and subdirectories (or `aws s3 sync`).

After this is complete, you can go to the url of the CloudFront distribution in your browser and you should see the contents of your static site.

## Module Reference (Inputs & Outputs)

### Inputs

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `bucket_name` | `string` | **Required** | Name of the S3 bucket to create |
| `force_destroy` | `bool` | `false` | Allow destroying bucket even if non-empty |
| `site_domain_name` | `string` | `null` | Primary domain name (e.g. `example.com`) |
| `alternate_domains` | `list(string)` | `[]` | SANs for ACM cert / CloudFront aliases |
| `acm_certificate_arn` | `string` | `null` | Pre-existing validated ACM cert ARN |
| `oac_name` | `string` | `"s3_static_site_oac"` | Name of CloudFront OAC |
| `default_root_object` | `string` | `"index.html"` | Default root object |
| `price_class` | `string` | `"PriceClass_100"` | CloudFront Price Class |
| `geo_restriction_type` | `string` | `"none"` | Geo restriction type (`none`, `whitelist`, `blacklist`) |
| `geo_restriction_locations` | `list(string)` | `[]` | ISO country codes for geo restriction |
| `cache_policy_id` | `string` | `"658327ea-f89d-4edd-b63e-4d97a025e948"` | CloudFront Cache Policy ID (`CachingOptimized`) |
| `enable_security_headers` | `bool` | `true` | Attach Security Headers Policy (HSTS, Frame-Options, etc.) |
| `response_headers_policy_id` | `string` | `null` | Custom CloudFront Response Headers Policy ID |
| `common_tags` | `map(string)` | `{}` | Tags to apply to all resources |

### Outputs

| Name | Description |
| :--- | :--- |
| `bucket_name` | Name (ID) of the created S3 bucket |
| `bucket_arn` | ARN of the created S3 bucket |
| `bucket_regional_domain_name` | Regional domain name of the S3 bucket |
| `distribution_id` | CloudFront Distribution ID |
| `distribution_domain_name` | CloudFront Distribution domain name |
| `distribution_arn` | ARN of the CloudFront Distribution |
| `acm_certificate_arn` | ARN of the ACM certificate |
| `domain_validation_options` | DNS CNAME records required for ACM validation |
| `response_headers_policy_id` | ID of the applied Response Headers Policy |

### Your DNS {#dns}

Assuming that you have your own domain that you entered into the variables section and you have run the apply, the ACM certificate is created. However, you cannot access your site from the domain yet until DNS is set up. You will need to go to your domain registrar or provider's website and set up several DNS records. You can find the values for these records in the AWS Console in your ACM certificate (or from the `domain_validation_options` output). For each domain and alternate domain you specified in the Terraform you will need to create an ALIAS/CNAME record that points to the CloudFront distribution as well as a CNAME record that points to the ACM certificate for DNS validation. Once these have been set up and the DNS cache has been refreshed, you should be able to go to your domain and see your static website.

Alternatively, there is a way to configure Terraform to output the values of the DNS records and answers that you need so that you don't need to access the AWS Console at all. It will involve setting up outputs in both the module and the main terraform directory. Read the [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) for ACM to learn more.

## The End

I recommend looking in the AWS console to see what you've just created and compare it side by side with the terraform in the module. It will really help you get a feel for what you've done.

If you want to create more than just a static site, then good news! You can use this module in conjunction with your other Terraform. No guarantees that you won't have to modify a part of the module to fit your specific use case though.

If you no longer wish to maintain your infrastructure that has just been created, run the command `terraform destroy`. Once this is complete, all of your AWS resources will have been deleted.
