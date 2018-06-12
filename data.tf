data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ip_ranges" "current_region_codebuild" {
  regions  = ["${data.aws_region.current.name}"]
  services = ["codebuild"]
}

data "template_file" "buildspec" {
  template = "${var.buildspec}"

  vars {
    ami-manifest-bucket       = "${var.ami_manifest_bucket}"
    ami-baking-pipeline-name  = "${local.bake_pipeline_name}"
    template-instance-profile = "${module.template_instance_role.instance_profile_name}"
    template-instance-sg      = "${aws_security_group.template.id}"
    base-ami-owners           = "${join(",", var.base_ami_owners)}"
    subnet-id                 = "${var.subnet_id}"
    vpc-id                    = "${var.vpc_id}"
    region                    = "${data.aws_region.current.name}"
  }
}

data "aws_iam_policy_document" "codebuild_s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.pipeline_artifact_bucket}/*",
      "arn:aws:s3:::${var.ami_manifest_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.pipeline_artifact_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucket",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.binary_bucket}",
      "arn:aws:s3:::${var.binary_bucket}/${var.binary_key}",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.bake_pipeline_name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.bake_pipeline_name}:*",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_packer" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:RunInstances",
    ]

    resources = [
      # these resources might need to be more 'locked down'
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key-pair/packer_*",

      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:launch-template/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:placement-group/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/${aws_security_group.template.id}",
      "arn:aws:ec2:${data.aws_region.current.name}::snapshot/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/${var.subnet_id}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:RunInstances",
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:volume/*",
    ]

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"

      values = [
        "special",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/ProductDomain"

      values = [
        "${var.product_domain}",
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:RunInstances",
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}::image/*",
    ]

    condition = {
      test     = "StringEquals"
      variable = "ec2:Owner"
      values   = "${var.base_ami_owners}"
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:RunInstances",
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
    ]

    condition = {
      test     = "StringEquals"
      variable = "ec2:InstanceProfile"

      values = [
        "${module.template_instance_role.instance_profile_name}",
        "${module.template_instance_role.instance_profile_arn}",
        "${module.template_instance_role.instance_profile_unique_id}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"

      values = [
        "Packer Builder",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/Service"

      values = [
        "${var.service_name}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/ProductDomain"

      values = [
        "${var.product_domain}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"

      values = [
        "special",
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:StopInstances",
      "ec2:TerminateInstances",
    ]

    resources = [
      "*",
    ]

    condition = {
      test     = "StringEquals"
      variable = "ec2:InstanceProfile"

      values = [
        "${module.template_instance_role.instance_profile_name}",
        "${module.template_instance_role.instance_profile_arn}",
        "${module.template_instance_role.instance_profile_unique_id}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"

      values = [
        "Packer Builder",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Service"

      values = [
        "${var.service_name}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/ProductDomain"

      values = [
        "${var.product_domain}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Environment"

      values = [
        "special",
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${module.template_instance_role.role_arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:DeregisterImage",
      "ec2:ModifyImageAttribute",
      "ec2:RegisterImage",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:ModifySnapshotAttribute",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateKeypair",
      "ec2:DeleteKeypair",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:ModifyInstanceAttribute",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateTags",
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:volume/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
    ]

    condition = {
      test     = "StringEquals"
      variable = "ec2:CreateAction"

      values = [
        "CreateVolume",
        "RunInstances",
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateTags",
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}::image/*",
      "arn:aws:ec2:${data.aws_region.current.name}::snapshot/*",
    ]

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/Service"

      values = [
        "${var.service_name}",
      ]
    }

    condition = {
      test     = "StringLike"
      variable = "aws:RequestTag/ServiceVersion"

      values = [
        "*",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/ProductDomain"

      values = [
        "${var.product_domain}",
      ]
    }

    condition = {
      test     = "StringLike"
      variable = "aws:RequestTag/BaseAmiId"

      values = [
        "*",
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "codepipeline_s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.pipeline_artifact_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucket",
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]

    resources = [
      "arn:aws:s3:::${var.playbook_bucket}",
      "arn:aws:s3:::${var.playbook_bucket}/${var.playbook_key}",
    ]
  }
}

data "aws_iam_policy_document" "codepipeline_codebuild" {
  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${aws_codebuild_project.bake_ami.name}"]
  }
}
