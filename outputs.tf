output "bake-ami-playbook-input" {
  value       = "s3://${var.pipeline-playbook-bucket}/${var.pipeline-playbook-key}"
  description = "where to store the zip file for the ami baking pipeline"
}

output "bake-ami-binary-input" {
  value       = "s3://${var.pipeline-binary-bucket}/${var.pipeline-binary-key}"
  description = "where to store the zip file for the ami baking pipeline"
}

output "bake-buildspec" {
  value       = "${data.template_file.buildspec.rendered}"
  description = "the bake-ami codebuild project's buildspec"
}
