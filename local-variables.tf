locals {
    bake-pipeline-name = "${var.service-name}-bake-ami"
    bake-pipeline-input-key = "${local.bake-pipeline-name}/${var.service-name}.zip"
    s3-bucket-name = "${substr(format("%s-%s-%s-%s", var.service-name,"codebuild-bake-ami", data.aws_caller_identity.current.account_id, random_string.s3-bucket-suffix.result), 0, 63)}"
}
