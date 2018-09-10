output "build_project_name" {
  value       = "${module.beisvc2_bake_ami.build_project_name}"
  description = "where to store the playbook zip file for the ami baking build"
}

output "bake_ami_playbook_input" {
  value       = "${module.beisvc2_bake_ami.bake_ami_playbook_input}"
  description = "where to store the playbook zip file for the ami baking build"
}

output "bake_ami_binary_input" {
  value       = "${module.beisvc2_bake_ami.bake_ami_binary_input}"
  description = "where to store the application tar file for the ami baking build"
}

output "bake_buildspec" {
  value       = "${module.beisvc2_bake_ami.bake_buildspec}"
  description = "the codebuild project's buildspec"
}
