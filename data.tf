data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "template_file" "buildspec" {
  template = "${var.buildspec}"

  vars {
    ami_manifest_bucket       = "${var.ami_manifest_bucket}"
    ami_baking_project_name   = "${local.bake_project_name}"
    template_instance_profile = "${var.template_instance_profile}"
    template_instance_sg      = "${var.template_instance_sg}"
    base_ami_owners           = "${join(",", var.base_ami_owners)}"
    subnet_id                 = "${var.subnet_id}"
    vpc_id                    = "${var.vpc_id}"
    region                    = "${data.aws_region.current.name}"
  }
}
