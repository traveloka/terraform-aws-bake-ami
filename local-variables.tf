locals {
    bake-pipeline-name = "${var.service-name}-bake-ami"
    bake-pipeline-input-key = "${local.bake-pipeline-name}/${var.service-name}.zip"
}

