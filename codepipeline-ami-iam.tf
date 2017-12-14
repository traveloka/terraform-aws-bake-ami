data "aws_iam_policy_document" "codepipeline-bake-ami-s3" {
  statement {
    effect = "Allow",
    actions = [
        "s3:GetBucketVersioning"
    ]
    resources = [
        "arn:aws:s3:::${var.service-s3-bucket}"
    ]
  }
  statement {
    effect = "Allow",
    actions = [
        "s3:GetObject",
        "s3:GetObjectVersion"
    ]
    resources = "${var.additional-s3-get-object-permissions}"
  }
  statement {
    effect = "Allow",
    actions = [
        "s3:PutObject"
    ]
    resources = [
        "arn:aws:s3:::${var.service-s3-bucket}/${local.bake-pipeline-name}/*/*"
    ]
  }
  statement {
    effect = "Allow",
    actions = [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
    ]
    resources = [ "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${aws_codebuild_project.bake-ami.name}" ]
  }
}

resource "aws_iam_role" "codepipeline-bake-ami" {
  name = "CodePipelineBakeAmi-${var.service-name}"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline-assume.json}"
}

resource "aws_iam_role_policy" "codepipeline-bake-ami-s3" {
  name = "CodePipelineBakeAmi-${var.service-name}-S3"
  role = "${aws_iam_role.codepipeline-bake-ami.id}"
  policy = "${data.aws_iam_policy_document.codepipeline-bake-ami-s3.json}"
}
