variable "service_name" {
  type        = "string"
  description = "the name of the service"
}

variable "product_domain" {
  type        = "string"
  description = "the owner of this pipeline (e.g. team). This is used mostly for adding tags to resources"
}

variable "environment" {
  type        = "string"
  default     = "special"
  description = "The environment where this ami baking pipeline is provisioned"
}

variable "base_ami_owners" {
  type        = "list"
  description = "the owners (AWS account IDs) of the base AMIs that instances will be run from"
}

variable "base_ami_prefix" {
  type        = "string"
  description = "The latest AMI which name follows this prefix will be used as the base AMI of your app AMI"
}

variable "app_ami_prefix" {
  type        = "string"
  description = "The created app AMI will be named with this prefix"
}

variable "vpc_id" {
  type        = "string"
  description = "the id of the VPC where AMI baking instances will reside on"
}

variable "subnet_id" {
  type        = "string"
  description = "the id of the subnet where AMI baking instances will reside on"
}

variable "bake_codebuild_compute_type" {
  type        = "string"
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "engineering_manifest_bucket" {
  type        = "string"
  description = "the bucket where ami build manifests will be uploaded to"
}

variable "bake_codebuild_image" {
  type        = "string"
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default     = "015110552125.dkr.ecr.ap-southeast-1.amazonaws.com/bei-codebuild-ami-baking-app:1.3.0"
}

variable "bake_codebuild_image_credentials" {
  type        = "string"
  default     = "SERVICE_ROLE"
  description = "Credentials to be used to pull codebuild environment image"
}

variable "bake_codebuild_environment_type" {
  type        = "string"
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli"
  default     = "LINUX_CONTAINER"
}

variable "codebuild_cache_bucket" {
  type        = "string"
  description = "An S3 bucket to be used as CodeBuild's cache bucket"

  # default to no cache
  default = ""
}

variable "template_instance_profile" {
  type        = "string"
  description = "The name of the instance profile with which AMI baking instances will run"
}

variable "template_instance_sg" {
  type        = "string"
  description = "The id of the security group with which AMI baking instances will run"
}

variable "codebuild_role_arn" {
  type        = "string"
  description = "The role arn to be assumed by the codebuild project"
}