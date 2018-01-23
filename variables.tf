variable "service-name" {
  type    = "string"
  description = "the name of the service"
}

variable "service-s3-bucket" {
  type = "string"
  description = "the bucket name that will be CodePipeline artifact store. CodeBuild will access this too in the 'DOWNLOAD_SOURCE' phase"
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

variable "additional-s3-put-object-permissions" {
  type    = "list"
  description = "S3 paths CodeBuild and CodePipeline will also have PutObject permission to."
  default = []
}

variable "additional-s3-get-object-permissions" {
  type    = "list"
  description = "S3 paths CodeBuild and CodePipeline will also have Get and GetObjectVersion permission to."
  default = []
}

variable "poll-source-changes" {
  default = "true"
  description = "Set whether the created pipeline should poll the source for change and triggers the pipeline"
}

variable "vpc-id" {
  description = "the id of VPC where the baking AMI instance will reside on"
}
