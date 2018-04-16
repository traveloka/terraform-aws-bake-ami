variable "service-name" {
  type        = "string"
  description = "the name of the service"
}

variable "product-domain" {
  type        = "string"
  description = "the owner of this pipeline (e.g. team). This is used mostly for adding tags to resources"
}

variable "base-ami-owners" {
  type        = "list"
  description = "the owners (AWS account IDs) of the base AMIs that instances will be run from"
}

variable "poll-source-changes" {
  default     = "true"
  description = "Set whether the created pipeline should poll the source for change and triggers the pipeline"
}

variable "pipeline-playbook-bucket" {
  type        = "string"
  description = "the S3 bucket that contains the AMI baking playbook"
}

variable "pipeline-binary-bucket" {
  type        = "string"
  description = "the S3 bucket that contains the application binary"
}

variable "ami-manifest-bucket" {
  type        = "string"
  description = "the S3 bucket to which CodeBuild will store the resulting AMI's artifacts"
}

variable "pipeline-playbook-key" {
  description = "the S3 key of the AMI baking playbook that will be used as the pipeline input. CodeBuild doesn't seem to support tar files"
}

variable "pipeline-binary-key" {
  description = "the S3 key of the Application binary that will be used as the pipeline input"
}

variable "codepipeline_role_arn" {
  description = "the role arn for codepipeline"
}

variable "codebuild_role_arn" {
  description = "the role arn for codebuild"
}

variable "template_instance_profile_name" {
  description = "the instance profile to be used by the template instance"
}

variable "vpc-id" {
  description = "the id of the VPC where AMI baking instances will reside on"
}

variable "subnet-id" {
  description = "the id of the subnet where AMI baking instances will reside on"
}

variable "bake-codebuild-compute-type" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "bake-codebuild-image" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default     = "traveloka/ansible-packer-codebuild-builder:0.1.6"
}

variable "bake-codebuild-environment-type" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli"
  default     = "LINUX_CONTAINER"
}

variable "s3-expiration-days" {
  description = "https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-lifecycle.html"
  default     = "14"
}

variable "s3-abort-incomplete-multipart-upload-days" {
  description = "https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-lifecycle.html"
  default     = "7"
}
