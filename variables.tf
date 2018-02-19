variable "service-name" {
  type    = "string"
  description = "the name of the service"
}

variable "product-domain" {
  type    = "string"
  description = "the owner of this pipeline (e.g. team). This is used mostly for adding tags to resources"
}

variable "base-ami-owners" {
  type    = "list"
  description = "the owners (AWS account IDs) of the base AMIs that instances will be run from"
}

variable "buildspec" {
  type    = "string"
  description = "the buildspec for the CodeBuild project"
}

variable "additional-codebuild-permission" {
  type    = "list"
  description = "Additional policies (in JSON) to be given to codebuild IAM Role"
  default = []
}

variable "poll-source-changes" {
  default = "true"
  description = "Set whether the created pipeline should poll the source for change and triggers the pipeline"
}

variable "vpc-id" {
  description = "the id of the VPC where AMI baking instances will reside on"
}

variable "subnet-id" {
  description = "the id of the subnet where AMI baking instances will reside on"
}

variable "bake-codebuild-compute-type" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html"
  default = "BUILD_GENERAL1_SMALL"
}

variable "bake-codebuild-image" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default = "aws/codebuild/java:openjdk-8"
}

variable "bake-codebuild-environment-type" {
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli"
  default = "LINUX_CONTAINER"
}

variable "s3-previous-version-ia-transition-days" {
  description = "https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-lifecycle.html"
  default = "30"
}

variable "s3-previous-version-glacier-transition-days" {
  description = "https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-lifecycle.html"
  default = "60"
}

variable "s3-previous-version-expiration-days" {
  description = "https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-lifecycle.html"
  default = "90"
}

variable "s3-abort-incomplete-multipart-upload-days" {
  description = "https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-lifecycle.html"
  default = "7"
}
