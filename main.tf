resource "aws_codebuild_project" "bake-ami" {
  name         = "${local.bake-pipeline-name}"
  description  = "Bake ${var.service-name} AMI"
  service_role = "${module.codebuild-bake-ami.role_arn}"

  artifacts {
    type           = "CODEPIPELINE"
    namespace_type = "BUILD_ID"
    packaging      = "ZIP"
  }

  environment {
    compute_type = "${var.bake-codebuild-compute-type}"
    image        = "${var.bake-codebuild-image}"
    type         = "${var.bake-codebuild-environment-type}"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }

  # cache {
  #   type     = "S3"
  #   location = "${aws_s3_bucket.cache.bucket}/${local.bake-pipeline-name}"
  # }

  tags {
    "Name"          = "${local.bake-pipeline-name}"
    "Description"   = "Bake ${var.service-name} AMI"
    "Service"       = "${var.service-name}"
    "ProductDomain" = "${var.product-domain}"
    "Environment"   = "special"
    "ManagedBy"     = "Terraform"
  }
}

resource "aws_codepipeline" "bake-ami" {
  name     = "${local.bake-pipeline-name}"
  role_arn = "${module.codepipeline-bake-ami.role_arn}"

  artifact_store {
    location = "${aws_s3_bucket.cache.id}"
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
        S3Bucket             = "${var.pipeline-playbook-bucket}"
        S3ObjectKey          = "${var.pipeline-playbook-key}"
        PollForSourceChanges = "${var.poll-source-changes}"
      }

      run_order = 1
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Bake"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["Playbook"]
      version         = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.bake-ami.name}"
      }

      run_order = 1
    }
  }
}

module "codebuild-bake-ami" {
  source = "github.com/salvianreynaldi/terraform-aws-iam-role.git//modules/service?ref=fix%2Fremove-region-prompt"

  role_identifier            = "CodeBuild Bake AMI"
  role_description           = "Service Role for CodeBuild Bake AMI"
  role_force_detach_policies = true
  role_max_session_duration  = 43200

  aws_service = "codebuild.amazonaws.com"
}

resource "aws_iam_role_policy" "codebuild-bake-ami-policy-packer" {
  name   = "CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service-name}-packer"
  role   = "${module.codebuild-bake-ami.role_name}"
  policy = "${data.aws_iam_policy_document.codebuild-bake-ami-packer.json}"
}

resource "aws_iam_role_policy" "codebuild-bake-ami-policy-cloudwatch" {
  name   = "CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service-name}-cloudwatch"
  role   = "${module.codebuild-bake-ami.role_name}"
  policy = "${data.aws_iam_policy_document.codebuild-bake-ami-cloudwatch.json}"
}

resource "aws_iam_role_policy" "codebuild-bake-ami-policy-s3" {
  name   = "CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service-name}-S3"
  role   = "${module.codebuild-bake-ami.role_name}"
  policy = "${data.aws_iam_policy_document.codebuild-bake-ami-s3.json}"
}

resource "aws_iam_role_policy" "codebuild-bake-ami-policy-additional" {
  name   = "CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service-name}-${count.index}"
  role   = "${module.codebuild-bake-ami.role_name}"
  policy = "${var.additional-codebuild-permission[count.index]}"
  count  = "${length(var.additional-codebuild-permission)}"
}

module "codepipeline-bake-ami" {
  source = "github.com/salvianreynaldi/terraform-aws-iam-role.git//modules/service?ref=fix%2Fremove-region-prompt"

  role_identifier            = "CodePipeline Bake AMI"
  role_description           = "Service Role for CodePipeline Bake AMI"
  role_force_detach_policies = true
  role_max_session_duration  = 43200

  aws_service = "codepipeline.amazonaws.com"
}

resource "aws_iam_role_policy" "codepipeline-bake-ami-s3" {
  name   = "CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service-name}-S3"
  role   = "${module.codepipeline-bake-ami.role_name}"
  policy = "${data.aws_iam_policy_document.codepipeline-bake-ami-s3.json}"
}

resource "aws_iam_role_policy" "codepipeline-bake-ami-codebuild" {
  name   = "CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service-name}-CodeBuild"
  role   = "${module.codepipeline-bake-ami.role_name}"
  policy = "${data.aws_iam_policy_document.codepipeline-bake-ami-codebuild.json}"
}

module "cache_bucket_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.0"

  name_prefix   = "${var.service-name}-codebuild-cache-"
  resource_type = "s3_bucket"
  keepers       = {}
}

resource "aws_s3_bucket" "cache" {
  bucket        = "${module.cache_bucket_name.name}"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true

    expiration {
      days                         = "${var.s3-expiration-days}"
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload_days = "${var.s3-abort-incomplete-multipart-upload-days}"
  }

  tags {
    Name          = "${module.cache_bucket_name.name}"
    Service       = "${var.service-name}"
    ProductDomain = "${var.product-domain}"
    Description   = "${var.service-name} ami baking S3 bucket"
    Environment   = "special"
    ManagedBy     = "Terraform"
  }
}

data "aws_vpc" "selected" {
  id = "${var.vpc-id}"
}

module "sg_name" {
  source = "git@github.com:traveloka/terraform-aws-resource-naming.git?ref=v0.6.0"

  name_prefix   = "${var.service-name}-template"
  resource_type = "security_group"
}

resource "aws_security_group" "template" {
  name   = "${module.sg_name.name}"
  vpc_id = "${var.vpc-id}"

  tags {
    Name          = "${var.service-name}-template"
    Service       = "${var.service-name}"
    ProductDomain = "${var.product-domain}"
    Environment   = "special"
    Description   = "Security group for ${var.service-name} ami baking instances"
    ManagedBy     = "Terraform"
  }
}

resource "aws_security_group_rule" "template-ssh" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["${data.aws_ip_ranges.current_region_codebuild.cidr_blocks}"]
}

resource "aws_security_group_rule" "template-http-all" {
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "template-https-all" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "template-all-vpc" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["${data.aws_vpc.selected.cidr_block}"]
}

module "template" {
  source = "github.com/salvianreynaldi/terraform-aws-iam-role.git//modules/instance?ref=fix%2Fremove-region-prompt"

  service_name = "${var.service-name}"
  cluster_role = "template"
}

resource "aws_iam_role_policy" "template-instance-additional" {
  name   = "TemplateInstance-${data.aws_region.current.name}-${var.service-name}-${count.index}"
  role   = "${module.template.role_name}"
  policy = "${var.additional-template-instance-permission[count.index]}"
  count  = "${length(var.additional-template-instance-permission)}"
}
