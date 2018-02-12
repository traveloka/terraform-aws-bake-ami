resource "aws_codepipeline" "bake-ami" {
  name     = "${local.bake-pipeline-name}"
  role_arn = "${aws_iam_role.codepipeline-bake-ami.arn}"

  artifact_store {
    location = "${aws_s3_bucket.bake-ami.id}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["Application"]

      configuration {
        S3Bucket = "${aws_s3_bucket.bake-ami.id}"
        S3ObjectKey = "${local.bake-pipeline-input-key}"
        PollForSourceChanges = "${var.poll-source-changes}"
      }
      run_order = 1
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Bake"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["Application"]
      version         = "1"
    
      configuration {
        ProjectName = "${aws_codebuild_project.bake-ami.name}"
      }
      run_order = 1
    }
  }
}
