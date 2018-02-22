locals {
    bake-pipeline-name = "${var.service-name}-bake-ami"
    s3-bucket-name = "${substr(format("%s-%s-%s-%s", var.service-name,"codebuild-cache", data.aws_caller_identity.current.account_id, random_string.s3-bucket-suffix.result), 0, 63)}"
}
