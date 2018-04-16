data "template_file" "buildspec" {
  template = <<EOF
version: 0.2
env:
  variables:
    USER: "ubuntu"
    PACKER_NO_COLOR: "true"
    APP_TEMPLATE_SG_ID: "$${template-instance-sg}"
    APP_S3_PREFIX: "s3://$${ami-manifest-bucket}/$${ami-baking-pipeline-name}"
    APP_TEMPLATE_INSTANCE_PROFILE: "$${template-instance-profile}"
    APP_TEMPLATE_INSTANCE_VPC_ID: "$${vpc-id}"
    APP_TEMPLATE_INSTANCE_SUBNET_ID: "$${subnet-id}"
    STACK_AMI_OWNERS: "$${base-ami-owners}"
    STACK_AMI_NAME_FILTER: "tvlk/ubuntu/tsi/java/hvm/x86_64/*"
    PACKER_VARIABLES_FILE: "packer_variables.json"
phases:
  pre_build:
    commands:
      - ansible-galaxy install -r requirements.yml
      - packer validate -var-file=$$$${PACKER_VARIABLES_FILE} /root/aws-ebs-traveloka-ansible.json
  build:
    commands:
      - packer build -var-file=$$$${PACKER_VARIABLES_FILE} /root/aws-ebs-traveloka-ansible.json
  post_build:
    commands:
      - jq ".builds[0].artifact_id" packer-manifest.json | grep -oE "ami-[a-f0-9]+" > instance-ami-id.tfvars
      - aws s3 cp . s3://$${ami-manifest-bucket}/$(cat instance-ami-id.tfvars)/ --recursive
cache:
  paths:
    - /root/.ansible/roles/**/*
EOF

  vars {
    ami-manifest-bucket       = "${var.ami-manifest-bucket}"
    ami-baking-pipeline-name  = "${local.bake-pipeline-name}"
    template-instance-profile = "${var.template_instance_profile_name}"
    template-instance-sg      = "${aws_security_group.template.id}"
    base-ami-owners           = "${join(",", var.base-ami-owners)}"
    subnet-id                 = "${var.subnet-id}"
    vpc-id                    = "${var.vpc-id}"
    region                    = "${data.aws_region.current.name}"
  }
}

resource "aws_codebuild_project" "bake-ami" {
  name         = "${local.bake-pipeline-name}"
  description  = "Bake ${var.service-name} AMI"
  service_role = "${var.codebuild_role_arn}"

  artifacts {
    type           = "CODEPIPELINE"
    namespace_type = "BUILD_ID"
    packaging      = "ZIP"
  }

  environment {
    compute_type = "${var.bake-codebuild-compute-type}"
    image        = "${var.bake-codebuild-image}"
    type         = "${var.bake-codebuild-environment-type}"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }

  tags {
    "Service"       = "${var.service-name}"
    "ProductDomain" = "${var.product-domain}"
    "Environment"   = "management"
  }
}
