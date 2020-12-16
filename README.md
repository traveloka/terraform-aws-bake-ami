# traveloka-terraform-aws-bake-ami

[![Release](https://img.shields.io/github/release/traveloka/traveloka-terraform-aws-bake-ami.svg)](https://github.com/traveloka/traveloka-terraform-aws-bake-ami/releases)
[![Last Commit](https://img.shields.io/github/last-commit/traveloka/traveloka-terraform-aws-bake-ami.svg)](https://github.com/traveloka/traveloka-terraform-aws-bake-ami/commits/master)
![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.png?v=103)

## Description


A Terraform module which creates a CodeBuild build project, along with their respective IAM roles and least-privilege policies.
This modules should be used to provision the AMI baking pipeline that can be used for various purpose, like application deployment to aws ec2 auto scaling groups


## Prerequisites

## Dependencies

This Terraform module have no dependencies to another modules


## Getting Started
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_codebuild\_tags | Additional tags to be added to codebuild | `map` | `{}` | no |
| additional\_codepipeline\_tags | Additional tags to be added to codepipeline | `map` | `{}` | no |
| ami\_manifest\_bucket | the S3 bucket to which CodeBuild will store the resulting AMI's artifacts | `string` | n/a | yes |
| bake\_codebuild\_compute\_type | https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| bake\_codebuild\_environment\_type | https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli | `string` | `"LINUX_CONTAINER"` | no |
| bake\_codebuild\_image | https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html | `string` | `"traveloka/codebuild-ami-baking:latest"` | no |
| base\_ami\_owners | the owners (AWS account IDs) of the base AMIs that instances will be run from | `list` | n/a | yes |
| buildspec | the buildspec for the CodeBuild project | `string` | n/a | yes |
| codebuild\_cache\_bucket | An S3 bucket to be used as CodeBuild's cache bucket | `string` | `""` | no |
| codebuild\_role\_arn | The role arn to be assumed by the codebuild project | `string` | n/a | yes |
| codepipeline\_artifact\_bucket | An S3 bucket to be used as CodePipeline's artifact bucket | `string` | n/a | yes |
| codepipeline\_poll\_for\_source\_changes | Whether or not the pipeline should poll for source changes | `string` | `"false"` | no |
| codepipeline\_role\_arn | The role arn to be assumed by the codepipeline | `string` | n/a | yes |
| events\_role\_arn | The role arn to be assumed by the cloudwatch events rule | `string` | n/a | yes |
| lambda\_function\_name | The name of the AMI sharing lambda function | `string` | n/a | yes |
| playbook\_bucket | the S3 bucket that contains the AMI baking playbook | `string` | n/a | yes |
| playbook\_key | the S3 key of the AMI baking playbook that will be used as the pipeline input. CodeBuild doesn't seem to support tar files | `string` | n/a | yes |
| product\_domain | the owner of this pipeline (e.g. team). This is used mostly for adding tags to resources | `string` | n/a | yes |
| service\_name | the name of the service | `string` | n/a | yes |
| slack\_channel | The name of the slack channel to which baked AMI IDs will be sent | `string` | `""` | no |
| subnet\_id | the id of the subnet where AMI baking instances will reside on | `string` | n/a | yes |
| template\_instance\_profile | The name of the instance profile with which AMI baking instances will run | `string` | n/a | yes |
| template\_instance\_sg | The id of the security group with which AMI baking instances will run | `string` | n/a | yes |
| vpc\_id | the id of the VPC where AMI baking instances will reside on | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bake\_ami\_playbook\_input | where to store the playbook zip file for the ami baking build |
| bake\_buildspec | the codebuild project's buildspec |
| build\_project\_name | the codebuild project name |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

This module accepting or open for any contributions from anyone, please see the [CONTRIBUTING.md](https://github.com/traveloka/terraform-aws-private-route53-zone/blob/master/CONTRIBUTING.md) for more detail about how to contribute to this module.

## License

This module is under Apache License 2.0 - see the [LICENSE](https://github.com/traveloka/terraform-aws-private-route53-zone/blob/master/LICENSE) file for details.