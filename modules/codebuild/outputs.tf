output "build_project_name" {
  value       = "${aws_codebuild_project.bake_ami.name}"
  description = "the codebuild project name"
}

output "bake_buildspec" {
  value       = "${data.template_file.ami_baking_buildspec.rendered}"
  description = "the codebuild project's buildspec"
}
