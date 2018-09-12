provider "aws" {
  region = "ap-southeast-1"
}

module "beisvc2_bake_ami" {
  source = "../../"

  service_name        = "beisvc2"
  product_domain      = "bei"
  playbook_bucket     = "beisvc2_artifact_bucket"
  binary_bucket       = "beisvc2_artifact_bucket"
  ami_manifest_bucket = "beisvc2_ami_bucket"

  base_ami_owners = [
    "123456789012",
  ]

  binary_key = "beisvc2*"
  vpc_id     = "${var.vpc_id}"
  subnet_id  = "${var.subnet_id}"
}
