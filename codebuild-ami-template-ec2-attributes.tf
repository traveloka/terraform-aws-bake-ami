data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

resource "aws_security_group" "template" {
  name   = "${var.service-name}-template"
  vpc_id = "${var.vpc-id}"

  tags {
    Name          = "${var.service-name}-template"
    Service       = "${var.service-name}"
    ProductDomain = "${var.product-domain}"
    Environment   = "special"
    Description   = "Security group for ${var.service-name} ami baking instances"
    ManagedBy     = "Terraform"
  }
}

resource "aws_security_group_rule" "template-ssh" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["${data.aws_ip_ranges.current_region_codebuild.cidr_blocks}"]
}

resource "aws_security_group_rule" "template-http-all" {
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "template-https-all" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "template-all-vpc" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  security_group_id = "${aws_security_group.template.id}"
  cidr_blocks       = ["${data.aws_vpc.selected.cidr_blocks}"]
}

module "template" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/instance?ref=v0.4.0"

  service_name = "${var.service-name}"
  cluster_role = "template"
}

resource "aws_iam_role_policy" "template-instance-additional" {
  name   = "TemplateInstance-${data.aws_region.current.name}-${var.service-name}-${count.index}"
  role   = "${module.template.role_id}"
  policy = "${var.additional-template-instance-permission[count.index]}"
  count  = "${length(var.additional-template-instance-permission)}"
}
