output "build_project_name" {
  value       = "${module.bake_ami.build_project_name}"
  description = "the codebuild project name"
}

output "bake_ami_playbook_input" {
  value       = "s3://${var.playbook_bucket}/${var.playbook_key}"
  description = "where to store the playbook zip file for the ami baking build"
}

output "bake_buildspec" {
  value       = "${module.bake_ami.bake_buildspec}"
  description = "the codebuild project's buildspec"
}
