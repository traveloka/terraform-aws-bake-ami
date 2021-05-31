module "bake_ami" {
  source = "modules/codebuild"

  app_ami_prefix              = "${var.app_ami_prefix}"
  base_ami_owners             = "${var.base_ami_owners}"
  base_ami_prefix             = "${var.base_ami_prefix}"
  codebuild_role_arn          = "${var.codebuild_role_arn}"
  engineering_manifest_bucket = "${var.engineering_manifest_bucket}"
  product_domain              = "${var.product_domain}"
  service_name                = "${var.service_name}"
  subnet_id                   = "${var.subnet_id}"
  template_instance_profile   = "${var.template_instance_profile}"
  template_instance_sg        = "${var.template_instance_sg}"
  vpc_id                      = "${var.vpc_id}"
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

      configuration = {
        S3Bucket             = "${var.playbook_bucket}"
        PollForSourceChanges = "${var.codepipeline_poll_for_source_changes}"
        S3ObjectKey          = "${var.playbook_key}"
      }

      run_order = "1"
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
      output_artifacts = ["PackerManifest", "BuildManifest"]
      version          = "1"

      configuration = {
        ProjectName = "${module.bake_ami.build_project_name}"
      }

      run_order = "1"
    }

    action {
      name            = "Share"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "Lambda"
      input_artifacts = ["PackerManifest", "Playbook"]
      version         = "1"

      configuration = {
        FunctionName   = "${var.lambda_function_name}"
        UserParameters = "${jsonencode(local.user_parameters)}"
      }

      run_order = "2"
    }
  }

  tags = {
    Name          = "${local.pipeline_name}"
    Description   = "${var.service_name} AMI Baking Pipeline"
    Service       = "${var.service_name}"
    ProductDomain = "${var.product_domain}"
    Environment   = "${var.environment}"
    ManagedBy     = "terraform"
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "${local.pipeline_name}-trigger"
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
      "PutObject",
      "CompleteMultipartUpload"
    ],
    "resources": {
      "ARN": [
        "arn:aws:s3:::${var.playbook_bucket}/${var.playbook_key}"
      ]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "this" {
  rule = "${aws_cloudwatch_event_rule.this.name}"
  arn  = "${aws_codepipeline.bake_ami.arn}"

  role_arn = "${var.events_role_arn}"
}
