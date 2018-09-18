resource "aws_codebuild_project" "bake_ami" {
  name         = "${local.bake_project_name}"
  description  = "Bake ${var.service_name} AMI"
  service_role = "${module.codebuild_role.role_arn}"

  artifacts {
    type           = "CODEPIPELINE"
    namespace_type = "BUILD_ID"
    packaging      = "ZIP"
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
    "Environment"   = "special"
    "ManagedBy"     = "Terraform"
  }
}

resource "aws_codepipeline" "bake_ami" {
  name     = "${local.pipeline_name}"
  role_arn = "${module.codepipeline_role.role_arn}"

  artifact_store {
    location = "${var.pipeline_artifact_bucket}"
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
        PollForSourceChanges = "${var.poll_source_changes}"
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
        ProjectName = "${aws_codebuild_project.bake_ami.name}"
      }

      run_order = 1
    }
  }
}

module "codebuild_role" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/service?ref=v0.4.3"

  role_identifier            = "CodeBuild Bake AMI"
  role_description           = "Service Role for CodeBuild Bake AMI"
  role_force_detach_policies = true
  role_max_session_duration  = 43200

  aws_service = "codebuild.amazonaws.com"
}

resource "aws_iam_role_policy" "codebuild-policy-packer" {
  name   = "CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service_name}-packer"
  role   = "${module.codebuild_role.role_name}"
  policy = "${data.aws_iam_policy_document.codebuild_packer.json}"
}

resource "aws_iam_role_policy" "codebuild_policy_cloudwatch" {
  name   = "CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service_name}-cloudwatch"
  role   = "${module.codebuild_role.role_name}"
  policy = "${data.aws_iam_policy_document.codebuild_cloudwatch.json}"
}

resource "aws_iam_role_policy" "codebuild_policy_s3" {
  name   = "CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service_name}-S3"
  role   = "${module.codebuild_role.role_name}"
  policy = "${data.aws_iam_policy_document.codebuild_s3.json}"
}

resource "aws_iam_role_policy" "codebuild_policy_additional" {
  name   = "CodeBuildBakeAmi-${data.aws_region.current.name}-${var.service_name}-${count.index}"
  role   = "${module.codebuild_role.role_name}"
  policy = "${var.additional_codebuild_permission[count.index]}"
  count  = "${length(var.additional_codebuild_permission)}"
}

module "codepipeline_role" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/service?ref=v0.4.3"

  role_identifier            = "CodePipeline Bake AMI"
  role_description           = "Service Role for CodePipeline Bake AMI"
  role_force_detach_policies = true
  role_max_session_duration  = 43200

  aws_service = "codepipeline.amazonaws.com"
}

resource "aws_iam_role_policy" "codepipeline_s3" {
  name   = "CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service_name}-S3"
  role   = "${module.codepipeline_role.role_name}"
  policy = "${data.aws_iam_policy_document.codepipeline_s3.json}"
}

resource "aws_iam_role_policy" "codepipeline_codebuild" {
  name   = "CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service_name}-CodeBuild"
  role   = "${module.codepipeline_role.role_name}"
  policy = "${data.aws_iam_policy_document.codepipeline_codebuild.json}"
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

module "sg_name" {
  source = "git@github.com:traveloka/terraform-aws-resource-naming.git?ref=v0.6.0"

  name_prefix   = "${var.service_name}-template"
  resource_type = "security_group"
}

resource "aws_security_group" "template" {
  name   = "${module.sg_name.name}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name          = "${var.service_name}-template"
    Service       = "${var.service_name}"
    ProductDomain = "${var.product_domain}"
    Environment   = "special"
    Description   = "Security group for ${var.service_name} ami baking instances"
    ManagedBy     = "Terraform"
  }
}

resource "aws_security_group_rule" "template_ssh" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["${data.aws_ip_ranges.current_region_codebuild.cidr_blocks}"]
}

resource "aws_security_group_rule" "template_http_all" {
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "template_https_all" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "template_all_vpc" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["${data.aws_vpc.selected.cidr_block}"]
}

module "template_instance_role" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/instance?ref=v0.4.3"

  service_name = "${var.service_name}"
  cluster_role = "template"
}

resource "aws_iam_role_policy" "template_instance_additional" {
  name   = "TemplateInstance-${data.aws_region.current.name}-${var.service_name}-${count.index}"
  role   = "${module.template_instance_role.role_name}"
  policy = "${var.additional_template_instance_permission[count.index]}"
  count  = "${length(var.additional_template_instance_permission)}"
}
