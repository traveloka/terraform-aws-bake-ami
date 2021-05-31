provider "aws" {
  region = "ap-southeast-1"
}

module "beitest_bake_ami" {
  source = "../../modules/codebuild"

  app_ami_prefix = "/app/"
  base_ami_owners = [
    "123456789012",
    "234567890123",
  ]
  base_ami_prefix = "/base/"
  codebuild_role_arn = "codebuild_role_arn"
  engineering_manifest_bucket = "bucket_eng"
  product_domain = "bei"
  service_name = "beitest"
  vpc_id    = "vpc-abcdef01"
  subnet_id = "subnet-23456789"
  template_instance_profile = "template_instance_profile"
  template_instance_sg = "template_instance_sg"
}
