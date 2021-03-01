locals {
  bake_project_name = "${var.service_name}-bake-ami"
  pipeline_name     = "${var.service_name}-ami-baking"
  user_parameters  = {
    "slack_channel" = "${var.slack_channel}"
    "target_accounts" = "${var.target_accounts}"
  }
}
