data "aws_acm_certificate" "primary_acm_wildcard_cert" {
  domain = "*.${var.primary_hosted_zone}"
}
