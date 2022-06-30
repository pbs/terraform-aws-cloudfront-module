resource "aws_cloudfront_origin_access_identity" "oia" {
  for_each = local.combined_s3_origins
  comment  = "CloudFront origin access identity for bucket ${each.value}."
}
