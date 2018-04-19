data "aws_iam_policy_document" "codebuild-bake-ami-s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cache.id}/*",
      "arn:aws:s3:::${var.ami-manifest-bucket}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cache.id}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucket",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.pipeline-binary-bucket}",
      "arn:aws:s3:::${var.pipeline-binary-bucket}/${var.pipeline-binary-key}",
    ]
  }
}

data "aws_iam_policy_document" "codebuild-bake-ami-cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.bake-pipeline-name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.bake-pipeline-name}:*",
    ]
  }
}

data "aws_iam_policy_document" "codebuild-bake-ami-packer" {
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
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/${var.subnet-id}",
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
        "management",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/ProductDomain"

      values = [
        "${var.product-domain}",
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
      values   = "${var.base-ami-owners}"
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
        "${module.template.instance_profile_name}",
        "${module.template.instance_profile_arn}",
        "${module.template.instance_profile_unique_id}",
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
        "${var.service-name}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/ProductDomain"

      values = [
        "${var.product-domain}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"

      values = [
        "management",
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
        "${module.template.instance_profile_name}",
        "${module.template.instance_profile_arn}",
        "${module.template.instance_profile_unique_id}",
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
        "${var.service-name}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/ProductDomain"

      values = [
        "${var.product-domain}",
      ]
    }

    condition = {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Environment"

      values = [
        "management",
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${module.template.role_arn}",
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
        "${var.service-name}",
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
        "${var.product-domain}",
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

module "codebuild-bake-ami" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/service?ref=v0.4.0"

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
