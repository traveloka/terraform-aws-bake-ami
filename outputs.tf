output "bake_ami_playbook_input" {
  value       = "s3://${var.pipeline_playbook_bucket}/${var.pipeline_playbook_key}"
  description = "where to store the zip file for the ami baking pipeline"
}

output "bake_ami_binary_input" {
  value       = "s3://${var.pipeline_binary_bucket}/${var.pipeline_binary_key}"
  description = "where to store the zip file for the ami baking pipeline"
}

output "bake_buildspec" {
  value       = "${data.template_file.buildspec.rendered}"
  description = "the codebuild project's buildspec"
}
