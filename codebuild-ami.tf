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
        compute_type = "BUILD_GENERAL1_SMALL"
        image        = "aws/codebuild/java:openjdk-8"
        type         = "LINUX_CONTAINER"
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
