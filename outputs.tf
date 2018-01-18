output "template-instance-sg" {
    value = "${aws_security_group.template.id}"
    description = "the id of the security group that this module creates. This should used by the baking AMI instances"
}

output "bake-ami-pipeline-input" {
    value = "s3://${var.service-s3-bucket}/${local.bake-pipeline-input-key}"
    description = "where to store the zip file for the ami baking pipeline"
}
