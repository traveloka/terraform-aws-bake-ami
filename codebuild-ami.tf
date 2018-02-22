data "template_file" "buildspec" {
  template = "${var.buildspec}"

  vars {
    ami-manifest-bucket = "${var.ami-manifest-bucket}"
    ami-baking-pipeline-name = "${local.bake-pipeline-name}"
    template-instance-profile = "${aws_iam_instance_profile.template.name}"
    template-instance-sg = "${aws_security_group.template.id}"
    base-ami-owners = "${join(",", var.base-ami-owners)}"
    subnet-id = "${var.subnet-id}"
    vpc-id = "${var.vpc-id}"
    region = "${data.aws_region.current.name}"
  }
}

resource "aws_codebuild_project" "bake-ami" {
    name         = "${local.bake-pipeline-name}"
    description  = "Bake ${var.service-name} AMI"
    service_role = "${aws_iam_role.codebuild-bake-ami.arn}"

    artifacts {
        type = "CODEPIPELINE"
        namespace_type = "BUILD_ID"
        packaging = "ZIP"
    }

    environment {
        compute_type = "${var.bake-codebuild-compute-type}"
        image        = "${var.bake-codebuild-image}"
        type         = "${var.bake-codebuild-environment-type}"
    }

    source {
        type     = "CODEPIPELINE"
        buildspec = "${data.template_file.buildspec.rendered}"
    }

    tags {
        "Service" = "${var.service-name}"
        "ProductDomain" = "${var.product-domain}"
        "Environment" = "management"
    }
}
