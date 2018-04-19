resource "aws_codepipeline" "bake-ami" {
  name     = "${local.bake-pipeline-name}"
  role_arn = "${module.codepipeline-bake-ami.role_arn}"

  artifact_store {
    location = "${aws_s3_bucket.cache.id}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Playbook"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["Playbook"]

      configuration {
        S3Bucket             = "${var.pipeline-playbook-bucket}"
        S3ObjectKey          = "${var.pipeline-playbook-key}"
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
      input_artifacts = ["Playbook"]
      version         = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.bake-ami.name}"
      }

      run_order = 1
    }
  }
}
