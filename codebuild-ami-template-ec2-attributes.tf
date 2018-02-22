resource "aws_security_group" "template" {
    name = "${var.service-name}-template"
    vpc_id = "${var.vpc-id}"
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${data.aws_ip_ranges.current_region_codebuild.cidr_blocks}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "${var.service-name}-template",
        Service = "${var.service-name}",
        ProductDomain = "${var.product-domain}",
        Environment = "management",
        Description = "security group for ${var.service-name} ami baking instances"
    }
}

resource "aws_iam_instance_profile" "template" {
  name = "profile-${var.service-name}-template-${data.aws_region.current.name}"
  role = "${aws_iam_role.template.name}"
}

resource "aws_iam_role" "template" {
  name = "profile-${var.service-name}-template-${data.aws_region.current.name}"
  assume_role_policy = "${data.aws_iam_policy_document.ec2-assume.json}"
}

resource "aws_iam_role_policy" "template-instance-additional" {
  name_prefix = "TemplateInstance-${data.aws_region.current.name}-${var.service-name}-"
  role = "${aws_iam_role.template.id}"
  policy = "${var.additional-template-instance-permission[count.index]}"
  count = "${length(var.additional-template-instance-permission)}"
}
