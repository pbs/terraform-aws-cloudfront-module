# PBS TF cloudfront module

## Installation

### Using the Repo Source

Use this URL for the source of the module. See the usage examples below for more details.

```hcl
github.com/pbs/terraform-aws-cloudfront-module?ref=x.y.z
```

### Alternative Installation Methods

More information can be found on these install methods and more in [the documentation here](./docs/general/install).

## Usage

This module creates a CloudFront distribution.

If configured to integrate with an S3 bucket, an origin access identity will be configured for the bucket.

Integrate this module like so:

```hcl
module "cloudfront" {
  source = "github.com/pbs/terraform-aws-cloudfront-module?ref=x.y.z"

  # Required Parameters
  primary_hosted_zone = "example.com"
  origins = [{
    domain_name = module.service.domain_name
    custom_origin_config = {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }]

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo

  # Optional Parameters
}
```

### :warning: Warning

Due to [#1](https://github.com/pbs/terraform-aws-cloudfront-module/issues/1), this module does not allow mixing of S3 origins and custom origins within the `origins` variable. In order to bypass this restriction, pending the general availability of optional object type attributes, use the `s3_origins` and `custom_origins` variables instead. Note that these variables cannot be used with the standard `origins` variable.

This is tested within the [combo](/examples/combo/main.tf) example.

e.g.

```hcl
module "service" {
  source = "github.com/pbs/terraform-aws-ecs-service-module?ref=0.0.1"

  name = "${var.product}-svc"

  primary_hosted_zone = var.primary_hosted_zone

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

module "s3" {
  source = "github.com/pbs/terraform-aws-s3-module?ref=0.0.1"

  force_destroy = true

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

module "cloudfront" {
  source = "github.com/pbs/terraform-aws-cloudfront-module?ref=x.y.z"

  primary_hosted_zone = var.primary_hosted_zone

  s3_origins     = [
    {
      domain_name      = module.s3.regional_domain_name
      s3_origin_config = module.s3.name
    }
  ]
  custom_origins = [
    {
      domain_name = module.service.domain_name
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "https-only"
        origin_read_timeout      = 30
        origin_ssl_protocols = [
          "TLSv1.2",
        ]
      }
    }
  ]

  default_root_object = "index.html"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}
```

## Adding This Version of the Module

If this repo is added as a subtree, then the version of the module should be close to the version shown here:

`x.y.z`

Note, however that subtrees can be altered as desired within repositories.

Further documentation on usage can be found [here](./docs).

Below is automatically generated documentation on this Terraform module using [terraform-docs][terraform-docs]

---

[terraform-docs]: https://github.com/terraform-docs/terraform-docs
