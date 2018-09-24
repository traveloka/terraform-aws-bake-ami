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
        S3Bucket    = "${var.playbook_bucket}"
        S3ObjectKey = "${var.playbook_key}"
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
      output_artifacts = ["AmiId"]
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
      input_artifacts = ["AmiId"]
      version         = "1"

      configuration {
        FunctionName = "${aws_codebuild_project.bake_ami.name}"
      }

      run_order = 1
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "trigger-${aws_codepipeline.bake_ami.name}"
  description = "Capture each s3://${var.playbook_bucket}/${var.playbook_key} upload"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject"
    ],
    "resources": [
      "arn:aws:s3:::${var.playbook_bucket}/${var.playbook_key}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "this" {
  rule = "${aws_cloudwatch_event_rule.this.name}"
  arn  = "${aws_codepipeline.bake_ami.arn}"

  role_arn = "${var.events_role_arn}"
}

resource "aws_lambda_function" "share_ami" {
  filename         = "${data.archive_file.share_ami_function.output_path}"
  source_code_hash = "${data.archive_file.share_ami_function.output_base64sha256}"
  role             = "${var.lambda_role_arn}"
  function_name    = "${var.service_name}-share-ami"
  description      = "share-${var.service_name}-amis"
  runtime          = "python3.6"
  handler          = "main.handler"
}
