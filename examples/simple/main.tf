provider "aws" {
  region = "ap-southeast-1"
}

module "beisvc2_bake_ami" {
  source = "../../"

  service-name             = "beisvc2"
  product-domain           = "bei"
  pipeline-playbook-bucket = "beisvc2_artifact_bucket"
  pipeline-binary-bucket   = "beisvc2_artifact_bucket"
  ami-manifest-bucket      = "beisvc2_ami_bucket"

  base-ami-owners = [
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

  pipeline-binary-key = "beisvc2*"
  vpc-id              = "vpc-abcd0123"
  subnet-id           = "subnet-4567efab"
}
