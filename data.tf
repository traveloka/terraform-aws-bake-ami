data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "template_file" "ami_baking_buildspec" {
  template = <<EOT
version: 0.2
env:
  variables:
    USER: "ubuntu"
    PACKER_NO_COLOR: "true"
    APP_TEMPLATE_SG_ID: "$${template_instance_sg}"
    APP_TEMPLATE_INSTANCE_PROFILE: "$${template_instance_profile}"
    APP_TEMPLATE_INSTANCE_VPC_ID: "$${vpc_id}"
    APP_TEMPLATE_INSTANCE_SUBNET_ID: "$${subnet_id}"
    AMI_NAME_PREFIX: "$${app_ami_prefix}"
    STACK_AMI_OWNERS: "$${base_ami_owners}"
    STACK_AMI_NAME_FILTER: "$${base_ami_prefix}"
phases:
  pre_build:
    commands:
      - ansible-galaxy install -r requirements.yml
      - packer validate -var-file="packer_variables.json" /root/aws-ebs-traveloka-ansible.json
  build:
    commands:
      - packer build -var-file="packer_variables.json" /root/aws-ebs-traveloka-ansible.json
  post_build:
    commands:
      - IMAGE_KEY=$(jq -r ".builds[0].artifact_id" packer-manifest.json | sed -e "s#:#/#g")
      - jq --arg image_key "$IMAGE_KEY" '.[0].builds[0] as $pm | .[1] | .deployment += {"packerManifest":$pm} | .image = $image_key' -s packer-manifest.json gradle_manifest.json > build_manifest.json  || touch build_manifest.json
      - aws s3 cp build_manifest.json s3://<engineering-manifest-bucket>/$IMAGE_KEY/build_manifest.json --sse AES256
artifacts:
  secondary-artifacts:
    PackerManifest:
      base-directory: $CODEBUILD_SRC_DIR
      files:
        - packer-manifest.json
    BuildManifest:
      base-directory: $CODEBUILD_SRC_DIR
      files:
        - build_manifest.json
EOT

  vars = {
    ami_baking_artifact_bucket       = "${var.engineering_manifest_bucket}"
    ami_baking_project_name   = "${local.bake_project_name}"
    template_instance_profile = "${var.template_instance_profile}"
    template_instance_sg      = "${var.template_instance_sg}"
    base_ami_owners           = "${join(",", var.base_ami_owners)}"
    base_ami_prefix          = "${var.base_ami_prefix}"
    app_ami_prefix           = "${var.app_ami_prefix}"
    subnet_id                 = "${var.subnet_id}"
    vpc_id                    = "${var.vpc_id}"
    region                    = "${data.aws_region.current.name}"
  }
}
