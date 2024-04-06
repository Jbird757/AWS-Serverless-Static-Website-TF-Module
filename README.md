# AWS Serverless Static Website TF Module
This repository contains a Terraform Module designed to create a static serverless website using AWS S3, CloudFront, and ACM. The intent is to introduce Terraform practices and concepts in a way that also supports best practices for severless hosting. 

## Prerequisites

1. A static website - even a simple index.html will do. The root of this site needs to be called index.html if you want to use the default configuration of the module.
2. An AWS account with an IAM user or role set up to allow access to terraform. It will need the following (simplified) permissions:

```
- AmazonS3FullAccess
- AmazonCertificateManagerFullAccess
- CloudFrontFullAccess
```
You will need to have previously signed in with this user on the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) in your local environment. After you have installed the CLI, begin this process with the `aws configure` command.

3. A domain name - not required, but if you do not have one you will have to make one up for the ACM certificate (it will point to nowhere) and you can access the site via the CloudFront domain.

## To Begin

Make a new directory (probably called "terraform") in your own website directory. Make a subdirectory in the terraform directory called "modules" and a further directory called something descriptive and copy the .tf files to the newest descriptive directory.
In the terraform directory, create 3 files, called `providers.tf`, `main.tf`, and `variables.tf`.
In the providers.tf file, copy and paste this code block:


```
terraform {
  required_version = ">=1.7.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }
}

```

This block sets the version of Terraform and the AWS provider.
Now, in the console in the `terraform/` directory you can run `terraform init` to initialize a terraform project. This will set up a backend in this directory that will keep track of changes made. You can also configure the backend to be in an [S3 bucket](https://developer.hashicorp.com/terraform/language/settings/backends/configuration), and for a website hosted on AWS that is probably the better choice. 

## Your Terraform
Look at the `modules/io.tf` file and view the variables and outputs. The variables are all inputs to the module. Some are required (those without a `default` attribute). You will need to define these values in your `variables.tf` and pass them into the module in your `main.tf`. 
Starting in the `variables.tf` folder, define all the variables you want to pass in. See prerequisites for questions about the domain name. [Here](https://developer.hashicorp.com/terraform/language/values/variables) is documentation on making variables. Terraform documentation is quite good. You will also need to create some outputs that take the output from the module and output it to the console if you want to see the S3 Bucket name and cloudfront distribution domain without needing to log into the AWS console (mostly applicable only if you don't have a domain that you're passing in). 

In the `main.tf` file in the `terraform` directory, reference the module with a module block and pass in the variables. Knowledge on how to do this can also be found in the Terraform Docs. For the source, use `source = "./modules/{your_descriptive_directory}`.

Now you can perform the next steps. It is always a good idea to validate your code, so run `terraform fmt` and `terraform validate` in the terraform directory. If there are no errors, you can go to the next step, which is to run `terraform plan`. This outputs exactly what Terraform plans to do in your AWS account. 

Now is a good time to go over what is actually going on in the Terraform Module. Take a look inside it and get familiar with the different resources which are defined in `resource` blocks in the `main.tf` file.

Once you understand what Terraform will do, run `terraform apply`. This will first do an additional plan, and once you confirm the plan, it will create the resources in AWS.

Once the apply is complete, you can run this command `aws s3 cp {file_name} s3://{Bucket Name}/` to upload your index.html file or run it specifying the directory which holds your static code with the `--recusive` flag for multiple files and subdirectories.

After this is complete, you can go to the CloudFront distribution in your browser and you should see the contents of your static site. 

### Your DNS

