output "template-instance-sg" {
    value = "${aws_security_group.template.id}"
    description = "the id of the security group that this module creates. This should used by the baking AMI instances"
}
