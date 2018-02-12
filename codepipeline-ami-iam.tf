data "aws_iam_policy_document" "codepipeline-bake-ami-s3" {
  statement {
    effect = "Allow",
    actions = [
        "s3:GetBucketVersioning"
    ]
    resources = [
        "arn:aws:s3:::${aws_s3_bucket.bake-ami.id}"
    ]
  }
  statement {
    effect = "Allow",
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bake-ami.id}/*"
    ]
  }
}

data "aws_iam_policy_document" "codepipeline-bake-ami-codebuild" {
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
  name = "CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service-name}"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline-assume.json}"
}

resource "aws_iam_role_policy" "codepipeline-bake-ami-s3" {
  name = "CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service-name}-S3"
  role = "${aws_iam_role.codepipeline-bake-ami.id}"
  policy = "${data.aws_iam_policy_document.codepipeline-bake-ami-s3.json}"
}

resource "aws_iam_role_policy" "codepipeline-bake-ami-codebuild" {
  name = "CodePipelineBakeAmi-${data.aws_region.current.name}-${var.service-name}-CodeBuild"
  role = "${aws_iam_role.codepipeline-bake-ami.id}"
  policy = "${data.aws_iam_policy_document.codepipeline-bake-ami-codebuild.json}"
}
