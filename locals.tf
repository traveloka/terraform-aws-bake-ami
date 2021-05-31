locals {
  pipeline_name = "${var.service_name}-ami-baking"
  user_parameters = {
    "slack_channel"  = "${var.slack_channel}"
    "targetAccounts" = "${var.target_accounts}"
  }
}
