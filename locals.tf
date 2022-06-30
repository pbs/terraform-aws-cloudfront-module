locals {
  name                   = var.name != null ? var.name : var.product
  cnames                 = var.cnames != null ? var.cnames : [local.name]
  aliases                = var.aliases != null ? var.aliases : ["${local.name}.${var.primary_hosted_zone}"]
  comment                = var.comment != null ? var.comment : "${local.aliases[0]} CDN."
  primary_hosted_zone_id = data.aws_route53_zone.primary_hosted_zone.zone_id
  acm_arn                = var.acm_arn != null ? var.acm_arn : data.aws_acm_certificate.primary_acm_wildcard_cert[0].arn
  domain_name            = var.create_cname && length(local.cnames) > 0 ? aws_route53_record.dns[0].fqdn : aws_cloudfront_distribution.cdn.domain_name

  #1 Necessary because optional types aren't part of Terraform yet.
  default_origin_id   = var.default_origin_id != null ? var.default_origin_id : length(var.origins) != 0 ? lookup(var.origins[0], "origin_id", var.origins[0].domain_name) : length(var.s3_origins) != 0 ? lookup(var.s3_origins[0], "origin_id", var.s3_origins[0].domain_name) : lookup(var.custom_origins[0], "origin_id", var.custom_origins[0].domain_name)
  combined_s3_origins = toset(compact(concat([for origin in var.origins : lookup(origin, "s3_origin_config", "")], [for origin in var.s3_origins : lookup(origin, "s3_origin_config", "")])))

  # Default cache behavior policies
  lookup_default_cache_policy_id            = var.default_cache_policy_id == null
  default_cache_policy_id                   = var.default_cache_policy_id != null ? var.default_cache_policy_id : data.aws_cloudfront_cache_policy.cache_policy[0].id
  lookup_default_origin_request_policy_id   = var.default_origin_request_policy_id == null && var.default_origin_request_policy_name != null
  default_origin_request_policy_id          = var.default_origin_request_policy_id != null ? var.default_origin_request_policy_id : local.lookup_default_origin_request_policy_id ? data.aws_cloudfront_origin_request_policy.origin_request_policy[0].id : null
  lookup_default_response_headers_policy_id = var.default_origin_request_policy_id == null && var.default_response_headers_policy_name != null
  default_response_headers_policy_id        = var.default_response_headers_policy_id != null ? var.default_response_headers_policy_id : local.lookup_default_response_headers_policy_id ? data.aws_cloudfront_response_headers_policy.response_headers_policy[0].id : null
  add_default_behavior_function_association = var.default_behavior_function_arn != null

  creator = "terraform"

  tags = merge(
    var.tags,
    {
      Name                                      = local.name
      "${var.organization}:billing:product"     = var.product
      "${var.organization}:billing:environment" = var.environment
      creator                                   = local.creator
      repo                                      = var.repo
    }
  )
}
