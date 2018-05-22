data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ip_ranges" "current_region_codebuild" {
  regions  = ["${data.aws_region.current.name}"]
  services = ["codebuild"]
}

resource "random_id" "s3-bucket-suffix" {
  byte_length = 8
}
