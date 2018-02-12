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
        buildspec = "${var.buildspec}"
    }

    tags {
        "Service" = "${var.service-name}"
        "ProductDomain" = "${var.product-domain}"
        "Environment" = "management"
    }
}
