resource "aws_cloudfront_origin_access_identity" "oia" {
  for_each = toset(compact([for origin in var.origins : lookup(origin, "s3_origin_config", "")]))
  comment  = "CloudFront origin access identity for bucket ${each.value}."
}
