resource "aws_s3_bucket" "cache" {
  bucket = "${local.s3-bucket-name}"
  acl    = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true

    expiration {
      days = "${var.s3-expiration-days}"
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
