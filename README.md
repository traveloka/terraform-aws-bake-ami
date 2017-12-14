# traveloka-terraform-aws-bake-ami
A Terraform module which creates a AWS CodePipeline pipeline, a CodeBuild build project, along with their respective IAM roles and least-privilege policies.
This modules should be used to provision the AMI baking pipeline that can be used for various purpose, like application deployment to aws ec2 auto scaling groups


## Usage
```
module "traveloka-aws-bake-ami" {
  source = "git@github.com:traveloka/traveloka-terraform-aws-bake-ami.git?ref=master"
  service-name = "traveloka-flight"
  service-s3-bucket = "flight-bucket-example"
  product-domain = "flight-team"
  additional-s3-get-object-permissions = [
    "arn:aws:s3:::flight-bucket-example/traveloka-flight-bake-ami/traveloka-flight.zip"
  ]
  additional-s3-put-object-permissions = [
    "arn:aws:s3:::flight-bucket-example/traveloka-flight-bake-ami/instance-ami-id-staging.tfvars",
    "arn:aws:s3:::flight-bucket-example/traveloka-flight-bake-ami/instance-ami-id-production.tfvars"
  ]
  base-ami-owners = [
    "0123456789012"
  ]
  buildspec = "buildspec-bake-ami.yml"
}
```

## Conventions
 - The created pipeline name will be ${var.service-name}-bake-ami
 - The pipeline source zip is an S3 object, located in `{var.service-s3-bucket}/${var.service-name}-bake-ami/${var.service-name}.zip`
 - The codepipeline IAM role name will be `CodePipelineBakeAmi-${var.service-name}`
 - The codepipeline IAM role inline policy name will be:
    - CodePipelineBakeAmi-${var.service-name}-S3
 - The created build project name will be ${var.service-name}-bake-ami
 - The build project environment image is `aws/codebuild/java:openjdk-8`
 - The build project will be tagged:
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
