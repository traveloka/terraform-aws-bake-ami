provider "aws" {
  region = "ap-southeast-1"
}

module "beitest_bake_ami" {
  source = "../../"

  codepipeline_artifact_bucket = "my_bucket"
  codepipeline_role_arn        = "codepipeline_arn"
  codebuild_cache_bucket       = "codebuild_cache_bucket"
  codebuild_role_arn           = "codebuild_role_arn"
  events_role_arn              = "events_role_arn"
  lambda_function_arn          = "lambda_function_arn"
  template_instance_profile    = "template_instance_profile"
  template_instance_sg         = "template_instance_sg"

  service_name        = "beitest"
  product_domain      = "bei"
  playbook_bucket     = "playbook_bucket"
  playbook_key        = "beitest/playbook.zip"
  ami_manifest_bucket = "playbook_bucket"

  base_ami_owners = [
    "123456789012",
    "234567890123",
  ]

  vpc_id    = "vpc-abcdef01"
  subnet_id = "subnet-23456789"

  buildspec = <<EOF
version: 0.2
env:
  variables:
    USER: "ubuntu"
    PACKER_NO_COLOR: "true"
    APP_TEMPLATE_SG_ID: "$${template_instance_sg}"
    APP_S3_PREFIX: "s3://$${ami_manifest_bucket}/$${ami_baking_project_name}"
    APP_TEMPLATE_INSTANCE_PROFILE: "$${template_instance_profile}"
    APP_TEMPLATE_INSTANCE_VPC_ID: "$${vpc_id}"
    APP_TEMPLATE_INSTANCE_SUBNET_ID: "$${subnet_id}"
    STACK_AMI_OWNERS: "$${base_ami_owners}"
    STACK_AMI_NAME_FILTER: "my_base_ami/*"
    PACKER_VARIABLES_FILE: "packer_variables.json"
phases:
  pre_build:
    commands:
      - ansible-galaxy install -r requirements.yml
      - packer validate -var-file=$$$${PACKER_VARIABLES_FILE} /root/aws-ebs-traveloka-ansible.json
  build:
    commands:
      - packer build -var-file=$$$${PACKER_VARIABLES_FILE} /root/aws-ebs-traveloka-ansible.json
cache:
  paths:
    - /root/.ansible/roles/**/*
artifacts:
  files:
    - packer-manifest.json
EOF
}
