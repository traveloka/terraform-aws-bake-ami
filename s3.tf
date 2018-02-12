resource "aws_s3_bucket" "bake-ami" {
  bucket = "${local.s3-bucket-name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    expiration {
        expired_object_delete_marker = true
    }

    noncurrent_version_transition {
      days          = "${var.s3-previous-version-ia-transition-days}"
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = "${var.s3-previous-version-glacier-transition-days}"
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = "${var.s3-previous-version-expiration-days}"
    }

    abort_incomplete_multipart_upload_days  = "${var.s3-abort-incomplete-multipart-upload-days}"
  }

  tags {
    Service = "${var.service-name}"
    ProductDomain = "${var.product-domain}"
    Description = "${var.service-name} ami baking S3 bucket"
    Environment = "management"
  }
}
