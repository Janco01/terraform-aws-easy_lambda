# AWS Easy lambda module

Terraform module which creates a lambda function very easily 

## Usage

```hcl
module "lambda" { 
    source = "terrakube-registry/jan-test-org/lambda/aws" 
    version = "" 
  
    archive_file = {
      source_file = "main.py"
      output_path = "main.zip"
    }

    lambda_function = {
      function_name = "print-helloworld"
      handler = "main.main"
      runtime = "python3.12"
    }
  
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.61 |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.61 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data |
| [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data |
| [aws_lambda_function.lambda_func](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="archive_file"></a> [archive\_file](#input\_archive\_file) | Object where you pass "source_file" and "output_path" | `object` | `null` | yes |
| <a name="lambda_function"></a> [lambda\_function](#input\_lambda\_function) | Object where you pass paramateres needed by the lambda function itself, params are, "function_name", "handler", "runtime". | `object` | `null` | yes |
| <a name="env_vars"></a> [env\_vars](#input\_env\_vars) | A map of all the environment variables that you want to pass to the lambda. | `map(string)` | `{ }` | no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | ARN for the lambda function |