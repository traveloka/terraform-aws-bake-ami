provider "aws" {
  region = "ap-southeast-1"
}

module "beisvc2_bake_ami" {
  source = "../../"

  pipeline_artifact_bucket = "${aws_s3_bucket.codepipeline_artifact.id}"
  service_name             = "beisvc2"
  product_domain           = "bei"
  playbook_bucket          = "beisvc2_artifact_bucket"
  binary_bucket            = "beisvc2_artifact_bucket"
  ami_manifest_bucket      = "beisvc2_ami_bucket"

  base_ami_owners = [
    "123456789012",
  ]

  binary_key = "beisvc2*"
  vpc_id     = "vpc-abcd0123"
  subnet_id  = "subnet-4567efab"
}

module "pipeline_artifact_bucket_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.1"

  name_prefix   = "beisvc2-codepipeline-artifact-"
  resource_type = "s3_bucket"
}

resource "aws_s3_bucket" "codepipeline_artifact" {
  bucket        = "${module.pipeline_artifact_bucket_name.name}"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 7
    }

    abort_incomplete_multipart_upload_days = 1
  }

  tags {
    Name          = "${module.pipeline_artifact_bucket_name.name}"
    Service       = "beisvc2"
    ProductDomain = "bei"
    Description   = "CodePipeline artifact bucket for bei services"
    Environment   = "special"
    ManagedBy     = "Terraform"
  }
}
