locals {
  bake-pipeline-name = "${var.service-name}-bake-ami"
  s3-bucket-name     = "${module.bucket_name.name}"
}

module "bucket_name" {
  source = "git@github.com:traveloka/terraform-aws-resource-naming.git?ref=v0.6.0"

  name_prefix   = "${format("%s-%s-%s", var.service-name,"codebuild-cache", data.aws_caller_identity.current.account_id)}"
  resource_type = "s3_bucket"
}
