output "bake-ami-pipeline-input" {
    value = "s3://${aws_s3_bucket.bake-ami.id}/${local.bake-pipeline-input-key}"
    description = "where to store the zip file for the ami baking pipeline"
}

output "bake-buildspec" {
  value = "${data.template_file.buildspec.rendered}"
  description = "the bake-ami codebuild project's buildspec"
}
