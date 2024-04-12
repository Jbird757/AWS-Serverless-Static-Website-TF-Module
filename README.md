# AWS Serverless Static Website TF Module
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
You will need to have previously signed in with this user on the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) in your local environment. After you have installed the CLI, begin this process with the `aws configure` command.

3. A domain name - not required, but if you do not have one you will have to access the site via the CloudFront domain, and the ACM certificate will not be used.

## To Begin

Make a new directory (probably called "terraform") in your own website directory. Make a subdirectory in the terraform directory called "modules" and another subdirectory in modules called something descriptive and copy the .tf files to the newest descriptive directory.
- In the terraform directory, create 3 files, called `providers.tf`, `main.tf`, and `terraform.tfvars`.
- In the providers.tf file, copy and paste this code block:


```
terraform {
  required_version = ">=1.7.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
      region = "us-east-1"
    }
  }
}

```

This block sets the version of Terraform and the AWS provider.
Now, in the console in the `terraform/` directory you can run `terraform init` to initialize a terraform project. For the purposes of this module, all Terraform commands should be run in the `terraform` directory. This will set up a backend in this directory that will keep track of changes made. You can also configure the backend to be in an [S3 bucket](https://developer.hashicorp.com/terraform/language/settings/backends/configuration), and for a website hosted on AWS that is probably the better choice. 

## Your Terraform
Look at the `io.tf` file and view the variables and outputs. The variables are all inputs to the module. Some are required (those without a `default` attribute). You will need to define these values in your `terraform.tfvars` file and reference them in your `terraform/main.tf` to pass them into the module.

Take note of the `tls_cert_validated` and `site_domain_name` variables. If you have a domain name, you will need to make 2 applies. The first will create the ACM certificate and the S3 bucket, and the second should be done after validating the ACM certificate ([see the DNS section](#dns)). Here are the ways to set these variables for the following scenarios:

- No domain name used: `tls_cert_validated = true`, `site_domain_name = null` (deafult)
- Have a domain name, the first time running: `tls_cert_validated = false` (deafult), `site_domain_name = {name of site}`
- Have a domain name, the second time running: `tls_cert_validated = true`, `site_domain_name = {name of site}`

Starting in the `terraform.tfvars` file, define and set values for all the local variables (called locals) you want to pass in. See prerequisites for questions about the domain name. [Here](https://developer.hashicorp.com/terraform/language/values/variables) is documentation on making locals. Terraform documentation is quite good.

You will also need to create some other variables, called outputs, that take the output from the module and output it to the console if you want to see the S3 Bucket name and cloudfront distribution domain without needing to log into the AWS console (mostly applicable only if you don't have a domain that you're passing in). 

In the `main.tf` file in the `terraform` directory, reference the module with a module block and pass in the variables. Knowledge on how to do this can also be found in the Terraform Docs. For the source attribute of the module block, use `source = "./modules/{your_descriptive_directory}`.

Now you can perform the next steps. First run `terraform init` again to initialize the new module. It is always a good idea to validate your code, so run `terraform fmt` and `terraform validate` in the terraform directory. If there are no errors, you can go to the next step, which is to run `terraform plan`. This outputs exactly what Terraform plans to do in your AWS account.

Now is a good time to go over what is actually going on in the Terraform Module. Take a look inside it and get familiar with the different resources which are defined in `resource` blocks in the `main.tf` file.

Once you understand what Terraform will do, run `terraform apply`. This will first do an additional plan, and once you confirm the plan, it will create the resources in AWS.

If you have your own domain name, you will need to run the apply twice, with different values of `tls_cert_validated`.

The apply will take several minutes. Usually it doesn't take this long, but creating a CloudFront Distribution is a slow process. Once it is complete, you can run this command from the directory that contains your index.html file `aws s3 cp {file_name} s3://{Bucket Name}/` to upload your index.html file or run it specifying the directory which holds your static code with the `--recursive` flag for multiple files and subdirectories.

After this is complete, you can go to the url of the CloudFront distribution in your browser and you should see the contents of your static site.

### Your DNS {#dns}

Assuming that you have your own domain that you entered into the variables section and you have ran the apply once, the ACM certificate is now correctly configured. However, you cannot access your site from the domain yet because DNS is still not set up. You will need to go to your domain registrar or provider's website and set up several DNS records. You can find the values for these records in the AWS Console in your ACM certificate that was just created. For each domain and alternate domain you specified in the Terraform you will need to create an ALIAS record that points to the CloudFront distribution as well as a CNAME record that points to the ACM certificate for DNS validation. Once these have been set up and the DNS cache has been refreshed, you should be able to go to your domain and see your static website.

Alternatively, there is a way to configure Terraform to output the values of the DNS records and answers that you need so that you don't need to access the AWS Console at all. It will involve setting up outputs in both the module and the main terraform directory. Read the [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) for ACM to learn more.

## The End

I recommend looking in the AWS console to see what you've just created and compare it side by side with the terraform in the module. It will really help you get a feel for what you've done.

If you want to create more than just a static site, then good news! You can use this module in conjunction with your other Terraform. No guarantees that you won't have to modify a part of the module to fit your specific use case though.

If you no longer wish to maintain your infrastructure that has just been created, run the command `terraform destroy`. Once this is complete, all of your AWS resources will have been deleted.
