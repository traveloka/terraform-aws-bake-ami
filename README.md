# traveloka-terraform-aws-bake-ami

A Terraform module which creates a CodeBuild build project, along with their respective IAM roles and least-privilege policies.
This modules should be used to provision the AMI baking pipeline that can be used for various purpose, like application deployment to aws ec2 auto scaling groups


## Usage

See examples/simple

## Conventions

 - The created pipeline name will be `${var.service_name}-bake-ami`
 - The created build project name will be `${var.service_name}-bake-ami`
 - The codebuild IAM role name will be `ServiceRoleForCodebuild_*`
 - The build project will be tagged:
    - "Service" = "${var.service_name}"
    - "ProductDomain" = "${var.product_domain}"
    - "Environment" = "special"
 - The build project will have permission to Run Instances:
    - having these tags on creation:
      - "Name" = "Packer Builder"
      - "Service" = "${var.service_name}"
      - "ProductDomain" = "${var.product_domain}"
      - "Environment" = "special"
    - with a volume having these tags on creation:
      - "ProductDomain" = "${var.product_domain}"
      - "Environment" = "special"
  - The build project will have permission to creates images and snapshots having these tags:
      - "Service" = "${var.service_name}"
      - "ServiceVersion" = any
      - "ProductDomain" = "${var.product_domain}"
      - "BaseAmiId" = any

## Authors

 - [Salvian Reynaldi](https://github.com/salvianreynaldi)


## License

Apache 2. See LICENSE for full details.
