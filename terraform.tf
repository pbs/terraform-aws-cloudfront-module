terraform {
  required_version = ">= 1.2.4"
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    aws = {
      version = ">= 4.27.0"
    }
  }
}
