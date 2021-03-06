variable "name" {
  description = "(optional) name of the distribution. Used as the default for DNS creation when configured"
  default     = null
  type        = string
}

variable "enabled" {
  description = "(optional) enable cloudfront"
  default     = true
  type        = bool
}

variable "is_ipv6_enabled" {
  description = "(optional) enable ipv6"
  default     = true
  type        = bool
}

variable "default_root_object" {
  description = "(optional) default root object to be served from cdn. e.g. index.hml"
  default     = null
  type        = string
}

variable "cloudfront_default_certificate" {
  description = "(optional) use cloudfront default ssl certificate"
  default     = false
  type        = bool
}

variable "minimum_protocol_version" {
  description = "(optional) tls minimum protocol version"
  default     = "TLSv1"
  type        = string
}

variable "ssl_support_method" {
  description = "(optional) ssl support method (one of vip or sni-only)"
  default     = "sni-only"
  type        = string
}

variable "default_behavior_allowed_methods" {
  description = "(optional) default behavior allowed methods"
  default     = ["GET", "HEAD"]
  type        = list(string)
}

variable "default_behavior_cached_methods" {
  description = "(optional) default behavior cached methods"
  default     = ["GET", "HEAD"]
  type        = list(string)
}

variable "default_origin_id" {
  description = "(optional) default origin origin id"
  default     = null
  type        = string
}

variable "default_behavior_function_event_type" {
  description = "(optional) default behavior function event type. If default_behavior_function_arn is null, this is ignored."
  default     = "viewer-request"
  type        = string
}

variable "default_behavior_function_arn" {
  description = "(optional) default behavior function arn. If null, no function is associated with default behavior."
  default     = null
  type        = string
}

variable "viewer_protocol_policy" {
  description = "(optional) viewer protocol policy"
  default     = "redirect-to-https"
  type        = string
}

variable "compress" {
  description = "(optional) gzip compress response"
  default     = true
  type        = bool
}

variable "price_class" {
  description = "(optional) price class for the distribution"
  default     = "PriceClass_100"
  type        = string
}

variable "restriction_type" {
  description = "(optional) type of restriction for CDN"
  default     = "none"
  type        = string
}

variable "restriction_locations" {
  description = "(optional) locations to use in access restriction (whitelist or blacklist based on restriction_type)"
  default     = []
  type        = list(string)
}

variable "aliases" {
  description = "(optional) CNAME(s) that are allowed to be used for this cdn. Default is `product`.`primary_hosted_zone`. e.g. [service.example.com] --> [service.example.com]"
  default     = null
  type        = list(string)
}

variable "cnames" {
  description = "(optional) CNAME(s) that are going to be created for this cdn in the primary_hosted_zone. This can be set to [] to avoid creating a CNAME for the app. This can be useful for CDNs. Default is `product`. e.g. [service] --> [example.example.com]"
  default     = null
  type        = list(string)
}

variable "create_cname" {
  description = "(optional) create CNAME(s) that point to CloudFront distribution"
  default     = true
  type        = bool
}

variable "comment" {
  description = "(optional) comment for the CDN"
  default     = null
  type        = string
}

variable "acm_arn" {
  description = "(optional) ARN for the ACM cert used for the CloudFront distribution"
  default     = null
  type        = string
}

variable "custom_error_response" {
  description = "(optional) set of one or more custom error response elements"
  default     = []
  type        = list(any)
}

variable "logging_config" {
  description = "(optional) logging configuration that controls how logs are written to your distribution (maximum one)"
  default     = []
  type        = list(any)
}

variable "ordered_cache_behavior" {
  description = "(optional) an ordered list of cache behaviors resource for this distribution"
  default     = []
  type        = list(any)
}

variable "web_acl_id" {
  description = "(optional) unique identifier that specifies the AWS WAF web ACL"
  default     = null
  type        = string
}

variable "dns_evaluate_target_health" {
  description = "(optional) evaluate health of endpoints by querying DNS records"
  default     = false
  type        = bool
}

variable "default_cache_policy_id" {
  description = "(optional) policy id for the cache policy of the default cache behavior. If null, a lookup on default_cache_policy_name will be attempted."
  default     = null
  type        = string
}

variable "default_cache_policy_name" {
  description = "(optional) policy name for the cache policy of the default cache behavior"
  default     = "Managed-CachingDisabled"
  type        = string
}

variable "default_origin_request_policy_id" {
  description = "(optional) policy id for the origin request policy of the default cache behavior. If null, a lookup on default_origin_request_policy_name will be attempted."
  default     = null
  type        = string
}

variable "default_origin_request_policy_name" {
  description = "(optional) policy name for the origin request policy of the default cache behavior"
  default     = null
  type        = string
}

variable "default_response_headers_policy_id" {
  description = "(optional) policy id for the response headers policy of the default cache behavior. If null, a lookup on default_response_headers_policy_name will be attempted."
  default     = null
  type        = string
}

variable "default_response_headers_policy_name" {
  description = "(optional) policy name for the response headers policy of the default cache behavior"
  default     = null
  type        = string
}
