resource "aws_security_group" "template" {
  name   = "${var.service-name}-template"
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
    Name          = "${var.service-name}-template"
    Service       = "${var.service-name}"
    ProductDomain = "${var.product-domain}"
    Environment   = "management"
    Description   = "security group for ${var.service-name} ami baking instances"
  }
}
