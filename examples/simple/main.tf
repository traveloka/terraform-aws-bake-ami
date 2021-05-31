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
  lambda_function_name         = "lambda_function_name"
  template_instance_profile    = "template_instance_profile"
  template_instance_sg         = "template_instance_sg"

  service_name        = "beitest"
  slack_channel       = "my_notification_channel"
  product_domain      = "bei"
  playbook_bucket     = "playbook_bucket"
  playbook_key        = "beitest/playbook.zip"

  base_ami_owners = [
    "123456789012",
    "234567890123",
  ]

  vpc_id    = "vpc-abcdef01"
  subnet_id = "subnet-23456789"

  app_ami_prefix = "/appname_prefix/"
  base_ami_prefix = "/base/"
  engineering_manifest_bucket = "bucket_eng"
}
