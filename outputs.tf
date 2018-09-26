output "build_project_name" {
  value       = "${aws_codebuild_project.bake_ami.name}"
  description = "the codebuild project name"
}

output "bake_ami_playbook_input" {
  value       = "s3://${var.playbook_bucket}/${var.playbook_key}"
  description = "where to store the playbook zip file for the ami baking build"
}

output "bake_buildspec" {
  value       = "${data.template_file.buildspec.rendered}"
  description = "the codebuild project's buildspec"
}
