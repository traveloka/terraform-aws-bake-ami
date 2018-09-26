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
    compute_type = "${var.bake_codebuild_compute_type}"
    image        = "${var.bake_codebuild_image}"
    type         = "${var.bake_codebuild_environment_type}"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }

  tags {
    "Name"          = "${local.bake_project_name}"
    "Description"   = "Bake ${var.service_name} AMI"
    "Service"       = "${var.service_name}"
    "ProductDomain" = "${var.product_domain}"
    "Environment"   = "management"
    "ManagedBy"     = "Terraform"
  }
}

resource "aws_codepipeline" "bake_ami" {
  name     = "${local.pipeline_name}"
  role_arn = "${var.codepipeline_role_arn}"

  artifact_store {
    location = "${var.codepipeline_artifact_bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Playbook"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["Playbook"]

      configuration {
        S3Bucket             = "${var.playbook_bucket}"
        S3ObjectKey          = "${var.playbook_key}"
        PollForSourceChanges = "true"
      }

      run_order = 1
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Bake"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Playbook"]
      output_artifacts = ["PackerManifest"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.bake_ami.name}"
      }

      run_order = 1
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Share"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "Lambda"
      input_artifacts = ["PackerManifest"]
      version         = "1"

      configuration {
        FunctionName = "${var.lambda_function_name}"
      }

      run_order = 1
    }
  }
}
