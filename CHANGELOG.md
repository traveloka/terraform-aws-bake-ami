## v2.2.5 (Oct 06, 2020)

NOTES:
* Add .pre-commit-config.yaml to include terraform_fmt and terraform_docs
* Update README.md to be informative

## v2.2.4 (Jul 19, 2019)

BUG FIXES:

* add tags to the codepipeline resource

## v2.2.3 (Mar 8, 2019)

BUG FIXES:

* Fix push trigger not working due to events rule pattern change

## v2.2.1 (Dec 20, 2018)

FEATURES:

* Rename events rule (#18) to manage IAM policy restriction easier

## v2.2.0 (Dec 19, 2018)

FEATURES:

* Add cloudwatch rule and target to enable push CodePipeline trigger

## v2.1.0 (Dec 11, 2018)

FEATURES:

* Add capability to specify which slack channel should be notified of the newly baked AMI. see the example directory

## v2.0.4 (Nov 7, 2018)

FEATURES:

* Configurable pipeline polling setting [#14] by [@bobbypriambodo](https://github.com/bobbypriambodo) useful as a workaround to the AWS maximum number of polling pipelines limit, which is 20

## v2.0.3 (Oct 3, 2018)

NOTES:

* This is Latest Stable, do not use v2.0.2

## v2.0.1 (Sep 28, 2018)

FEATURES:

* Forcing latest image by default

## v2.0.0 (Sep 27, 2018)

FEATURES:

* Decouple IAM Roles and Policies from the module

## v1.0.0 (Sep 12, 2018)

FEATURES:

* remove codepipeline
* omit service_name --> product domain related changes
* update readme, and description
* update wrong description
