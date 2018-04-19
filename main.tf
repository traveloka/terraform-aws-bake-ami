data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ip_ranges" "current_region_codebuild" {
  regions  = ["${data.aws_region.current.name}"]
  services = ["codebuild"]
}

data "aws_iam_policy_document" "ec2-assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild-assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline-assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "random_string" "s3-bucket-suffix" {
  length  = 30
  special = false
  upper   = false
}
