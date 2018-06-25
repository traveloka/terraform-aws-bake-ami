variable "service_name" {
  type        = "string"
  description = "the name of the service"
}

variable "product_domain" {
  type        = "string"
  description = "the owner of this pipeline (e.g. team). This is used mostly for adding tags to resources"
}

variable "base_ami_owners" {
  type        = "list"
  description = "the owners (AWS account IDs) of the base AMIs that instances will be run from"
}

variable "buildspec" {
  default = <<EOF
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

  description = "the buildspec for the CodeBuild project"
}

variable "additional_codebuild_permission" {
  type        = "list"
  description = "Additional policies (in JSON) to be given to the codebuild IAM Role"
  default     = []
}

variable "additional_template_instance_permission" {
  type        = "list"
  description = "Additional policies (in JSON) to be given to the template instance's IAM Role"
  default     = []
}

variable "poll_source_changes" {
  default     = "false"
  description = "Set whether the created pipeline should poll the source for change and triggers the pipeline"
}

variable "playbook_bucket" {
  type        = "string"
  description = "the S3 bucket that contains the AMI baking playbook"
}

variable "binary_bucket" {
  type        = "string"
  description = "the S3 bucket that contains the application binary"
}

variable "ami_manifest_bucket" {
  type        = "string"
  description = "the S3 bucket to which CodeBuild will store the resulting AMI's artifacts"
}

variable "playbook_key" {
  default     = "playbook.zip"
  description = "the S3 key of the AMI baking playbook that will be used as the pipeline input. CodeBuild doesn't seem to support tar files"
}

variable "binary_key" {
  default     = "application.tgz"
  description = "the S3 key of the Application binary that will be used as the pipeline input"
}

variable "vpc_id" {
  description = "the id of the VPC where AMI baking instances will reside on"
}

variable "subnet_id" {
  description = "the id of the subnet where AMI baking instances will reside on"
}

variable "bake_codebuild_compute_type" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "bake_codebuild_image" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default     = "traveloka/ansible-packer-codebuild-builder:0.1.7"
}

variable "bake_codebuild_environment_type" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli"
  default     = "LINUX_CONTAINER"
}

variable "pipeline_artifact_bucket" {
  description = "An S3 bucket to be used as CodePipeline's artifact bucket"
}
