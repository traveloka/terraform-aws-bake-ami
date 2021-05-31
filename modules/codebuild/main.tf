resource "aws_cloudwatch_log_group" "bake_ami" {
  name = "/aws/codebuild/${local.bake_project_name}"

  retention_in_days = "30"

  tags = {
    Name          = "/aws/codebuild/${local.bake_project_name}"
    ProductDomain = "${var.product_domain}"
    Service       = "${var.service_name}"
    Environment   = "management"
    Description   = "LogGroup for ${var.service_name} Bake AMI"
    ManagedBy     = "terraform"
  }
}

resource "aws_codebuild_project" "bake_ami" {
  name         = "${local.bake_project_name}"
  description  = "Bake ${var.service_name} AMI"
  service_role = "${var.codebuild_role_arn}"

  artifacts {
    type           = "CODEPIPELINE"
    namespace_type = "BUILD_ID"
    packaging      = "ZIP"
  }

  cache {
    type     = "${var.codebuild_cache_bucket == "" ? "NO_CACHE" : "S3"}"
    location = "${var.codebuild_cache_bucket}/${local.bake_project_name}"
  }

  environment {
    compute_type                = "${var.bake_codebuild_compute_type}"
    image                       = "${var.bake_codebuild_image}"
    image_pull_credentials_type = "${var.bake_codebuild_image_credentials}"
    type                        = "${var.bake_codebuild_environment_type}"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.ami_baking_buildspec.rendered}"
  }

  tags = {
    Name          = "${local.bake_project_name}"
    Description   = "Bake ${var.service_name} AMI"
    Service       = "${var.service_name}"
    ProductDomain = "${var.product_domain}"
    Environment   = "${var.environment}"
    ManagedBy     = "terraform"
  }
}
