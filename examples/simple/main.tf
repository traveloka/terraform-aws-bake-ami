provider "aws" {
  region = "ap-southeast-1"
}

module "beisvc2_bake_ami" {
  source = "../../"

  pipeline_artifact_bucket = "${aws_s3_bucket.codepipeline_artifact.id}"
  service_name             = "beisvc2"
  product_domain           = "bei"
  pipeline_playbook_bucket = "beisvc2_artifact_bucket"
  pipeline_binary_bucket   = "beisvc2_artifact_bucket"
  ami_manifest_bucket      = "beisvc2_ami_bucket"

  base_ami_owners = [
    "123456789012",
  ]

  buildspec = <<EOF
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
    STACK_AMI_NAME_FILTER: "traveloka/ubuntu/si/java/hvm/x86_64/*"
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
      - jq ".builds[0].artifact_id" packer-manifest.json | grep -oE "ami-[a-f0-9]" > instance-ami-id.tfvars
      - aws s3 cp . s3://$${ami-manifest-bucket}/$(cat instance-ami-id.tfvars)/ --recursive
cache:
  paths:
    - /root/.ansible/roles/**/*
EOF

  pipeline_binary_key = "beisvc2*"
  vpc_id              = "vpc-abcd0123"
  subnet_id           = "subnet-4567efab"
}

module "cache_bucket_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.1"

  name_prefix   = "beisvc2-codepipeline-artifact-"
  resource_type = "s3_bucket"
}

resource "aws_s3_bucket" "codepipeline_artifact" {
  bucket        = "${module.cache_bucket_name.name}"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 7
    }

    abort_incomplete_multipart_upload_days = 1
  }

  tags {
    Name          = "${module.cache_bucket_name.name}"
    Service       = "beisvc2"
    ProductDomain = "bei"
    Description   = "CodePipeline artifact bucket for bei services"
    Environment   = "special"
    ManagedBy     = "Terraform"
  }
}
