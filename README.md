# traveloka-terraform-aws-bake-ami
A Terraform module which creates a AWS CodePipeline pipeline, a CodeBuild build project, along with their respective IAM roles and least-privilege policies.
This modules should be used to provision the AMI baking pipeline that can be used for various purpose, like application deployment to aws ec2 auto scaling groups


## Usage
```
module "traveloka-aws-bake-ami" {
  source = "git@github.com:traveloka/traveloka-terraform-aws-bake-ami.git?ref=master"
  service-name = "traveloka-flight"
  product-domain = "flight-team"
  base-ami-owners = [
    "0123456789012"
  ]
  buildspec = "buildspec-bake-ami.yml"
  vpc-id = "vpc-57f4d83e"
}
```

## Conventions
 - The created pipeline name will be `${var.service-name}-bake-ami`
 - The created s3 bucket name will be `${var.service-name}-codebuild-bake-ami-${data.aws_caller_identity.current.account_id}-<random_string>`
 - The codepipeline IAM role name will be `CodePipelineBakeAmi-${var.service-name}`
 - The codepipeline IAM role inline policy name will be:
    - `CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service-name}-S3*`
    - `CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service-name}-CodeBuild`
 - The created build project name will be ${var.service-name}-bake-ami
 - The codebuild IAM role name will be `CodeBuildBakeAmi-${var.service-name}`
 - The codebuild IAM role inline policy name will be:
    - `CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service-name}-S3`
    - `CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service-name}-cloudwatch`
    - `CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service-name}-packer`
 - The build project will be tagged:
    - "Service" = "${var.service-name}"
    - "ProductDomain" = "${var.product-domain}"
    - "Environment" = "management"
 - The build project will have permission to Run Instances:
    - having these tags on creation:
      - "Name" = "Packer Builder"
      - "Service" = "${var.service-name}"
      - "ServiceVersion" = any
      - "Cluster" = "${var.service-name}-app"
      - "ProductDomain" = "${var.product-domain}"
      - "Environment" = "management"
      - "Application" = any
      - "Description" = any
    - with a volume having these tags on creation:
      - "ProductDomain" = "${var.product-domain}"
      - "Environment" = "management"
    - creates images and snapshots having these tags:
      - "Service" = "${var.service-name}"
      - "ServiceVersion" = any
      - "ProductDomain" = "${var.product-domain}"
      - "Application" = any
      - "SourceAmi" = any



## Authors

 - [Salvian Reynaldi](https://github.com/salvianreynaldi)


## License

Apache 2. See LICENSE for full details.
