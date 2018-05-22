# traveloka-terraform-aws-bake-ami
A Terraform module which creates a AWS CodePipeline pipeline, a CodeBuild build project, along with their respective IAM roles and least-privilege policies.
This modules should be used to provision the AMI baking pipeline that can be used for various purpose, like application deployment to aws ec2 auto scaling groups


## Usage
```
module "traveloka-aws-bake-ami" {
  source = "git@github.com:traveloka/traveloka-terraform-aws-bake-ami.git?ref=master"
  service-name = "traveloka-flight"
  product-domain = "flight-team"
  pipeline-playbook-bucket = "${aws_s3_bucket.appbin.id}"
  pipeline-binary-bucket = "${aws_s3_bucket.appbin.id}"
  ami-manifest-bucket = "${aws_s3_bucket.ami-manifest.id}"
  base-ami-owners = [
    "0123456789012"
  ]
  buildspec = "buildspec-bake-ami.yml"
  vpc-id = "vpc-57f4d83e"
}
```

## Conventions
 - The created pipeline name will be `${var.service-name}-bake-ami`
 - The codepipeline IAM role name will be `CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service-name}`
 - The created build project name will be `${var.service-name}-bake-ami`
 - The codebuild IAM role name will be `CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service-name}`
 - The build project will be tagged:
    - "Service" = "${var.service-name}"
    - "ProductDomain" = "${var.product-domain}"
    - "Environment" = "special"
 - The build project will have permission to Run Instances:
    - having these tags on creation:
      - "Name" = "Packer Builder"
      - "Service" = "${var.service-name}"
      - "ProductDomain" = "${var.product-domain}"
      - "Environment" = "special"
    - with a volume having these tags on creation:
      - "ProductDomain" = "${var.product-domain}"
      - "Environment" = "special"
  - The build project will have permission to creates images and snapshots having these tags:
      - "Service" = "${var.service-name}"
      - "ServiceVersion" = any
      - "ProductDomain" = "${var.product-domain}"
      - "BaseAmiId" = any

## Authors

 - [Salvian Reynaldi](https://github.com/salvianreynaldi)


## License

Apache 2. See LICENSE for full details.
