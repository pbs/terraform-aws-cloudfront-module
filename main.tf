resource "aws_cloudfront_distribution" "cdn" {
  lifecycle {
    precondition {
      condition     = (length(var.origins) != 0 && length(var.s3_origins) == 0 && length(var.custom_origins) == 0) || ((length(var.s3_origins) != 0 || length(var.custom_origins) != 0) && length(var.origins) == 0)
      error_message = "Either var.origins must be populated, or one or both of var.s3_origins + var.custom_origins must be populated."
    }
  }

  dynamic "origin" {
    for_each = var.origins
    iterator = origin
    content {
      connection_attempts = lookup(origin.value, "connection_attempts", null)
      connection_timeout  = lookup(origin.value, "connection_timeout", null)
      domain_name         = lookup(origin.value, "domain_name", null)
      origin_id           = lookup(origin.value, "origin_id", lookup(origin.value, "domain_name", null))
      origin_path         = lookup(origin.value, "origin_path", null)

      dynamic "custom_origin_config" {
        for_each = length(keys(lookup(origin.value, "custom_origin_config", {}))) == 0 ? [] : [origin.value.custom_origin_config]
        content {
          http_port                = lookup(custom_origin_config.value, "http_port", null)
          https_port               = lookup(custom_origin_config.value, "https_port", null)
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", null)
          origin_protocol_policy   = lookup(custom_origin_config.value, "origin_protocol_policy", null)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", null)
          origin_ssl_protocols     = lookup(custom_origin_config.value, "origin_ssl_protocols", null)
        }
      }

      dynamic "s3_origin_config" {
        for_each = toset(compact([for origin in var.origins : lookup(origin, "s3_origin_config", "")]))
        content {
          origin_access_identity = aws_cloudfront_origin_access_identity.oia[s3_origin_config.value].cloudfront_access_identity_path
        }
      }

      dynamic "origin_shield" {
        for_each = length(keys(lookup(origin.value, "origin_shield", {}))) == 0 ? [] : [origin.value.origin_shield]
        content {
          enabled              = lookup(origin_shield.value, "enabled", null)
          origin_shield_region = lookup(origin_shield.value, "origin_shield_region", null)
        }
      }
    }
  }

  dynamic "origin" {
    for_each = var.custom_origins
    iterator = origin
    content {
      connection_attempts = lookup(origin.value, "connection_attempts", null)
      connection_timeout  = lookup(origin.value, "connection_timeout", null)
      domain_name         = lookup(origin.value, "domain_name", null)
      origin_id           = lookup(origin.value, "origin_id", lookup(origin.value, "domain_name", null))
      origin_path         = lookup(origin.value, "origin_path", null)

      dynamic "custom_origin_config" {
        for_each = length(keys(lookup(origin.value, "custom_origin_config", {}))) == 0 ? [] : [origin.value.custom_origin_config]
        content {
          http_port                = lookup(custom_origin_config.value, "http_port", null)
          https_port               = lookup(custom_origin_config.value, "https_port", null)
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", null)
          origin_protocol_policy   = lookup(custom_origin_config.value, "origin_protocol_policy", null)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", null)
          origin_ssl_protocols     = lookup(custom_origin_config.value, "origin_ssl_protocols", null)
        }
      }

      dynamic "origin_shield" {
        for_each = length(keys(lookup(origin.value, "origin_shield", {}))) == 0 ? [] : [origin.value.origin_shield]
        content {
          enabled              = lookup(origin_shield.value, "enabled", null)
          origin_shield_region = lookup(origin_shield.value, "origin_shield_region", null)
        }
      }
    }
  }

  dynamic "origin" {
    for_each = var.s3_origins
    iterator = origin
    content {
      connection_attempts = lookup(origin.value, "connection_attempts", null)
      connection_timeout  = lookup(origin.value, "connection_timeout", null)
      domain_name         = lookup(origin.value, "domain_name", null)
      origin_id           = lookup(origin.value, "origin_id", lookup(origin.value, "domain_name", null))
      origin_path         = lookup(origin.value, "origin_path", null)

      dynamic "s3_origin_config" {
        for_each = local.combined_s3_origins
        content {
          origin_access_identity = aws_cloudfront_origin_access_identity.oia[s3_origin_config.value].cloudfront_access_identity_path
        }
      }

      dynamic "origin_shield" {
        for_each = length(keys(lookup(origin.value, "origin_shield", {}))) == 0 ? [] : [origin.value.origin_shield]
        content {
          enabled              = lookup(origin_shield.value, "enabled", null)
          origin_shield_region = lookup(origin_shield.value, "origin_shield_region", null)
        }
      }
    }
  }

  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = local.comment
  default_root_object = var.default_root_object
  web_acl_id          = var.web_acl_id

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
    acm_certificate_arn            = local.acm_arn
    minimum_protocol_version       = var.minimum_protocol_version
    ssl_support_method             = var.ssl_support_method
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response
    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  dynamic "logging_config" {
    for_each = var.logging_config
    content {
      bucket          = logging_config.value.logging_bucket
      include_cookies = logging_config.value.logging_cookies
      prefix          = logging_config.value.logging_prefix
    }
  }

  aliases = local.aliases

  default_cache_behavior {
    allowed_methods  = var.default_behavior_allowed_methods
    cached_methods   = var.default_behavior_cached_methods
    target_origin_id = local.default_origin_id

    viewer_protocol_policy = var.viewer_protocol_policy
    compress               = var.compress

    # Cache behavior policies
    cache_policy_id            = local.default_cache_policy_id
    origin_request_policy_id   = local.default_origin_request_policy_id
    response_headers_policy_id = local.default_response_headers_policy_id

    dynamic "function_association" {
      for_each = local.add_default_behavior_function_association ? [true] : []
      content {
        event_type   = var.default_behavior_function_event_type
        function_arn = var.default_behavior_function_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    iterator = behavior
    content {
      allowed_methods            = lookup(behavior.value, "allowed_methods", ["GET", "HEAD"])
      cached_methods             = lookup(behavior.value, "cached_methods", ["GET", "HEAD"])
      compress                   = lookup(behavior.value, "compress", true)
      path_pattern               = behavior.value["path_pattern"]
      smooth_streaming           = lookup(behavior.value, "smooth_streaming", null)
      target_origin_id           = behavior.value["target_origin_id"]
      trusted_key_groups         = lookup(behavior.value, "trusted_key_groups", [])
      trusted_signers            = lookup(behavior.value, "trusted_signers", [])
      viewer_protocol_policy     = lookup(behavior.value, "viewer_protocol_policy", "redirect-to-https")
      field_level_encryption_id  = lookup(behavior.value, "field_level_encryption_id", null)
      cache_policy_id            = behavior.value["cache_policy_id"]
      origin_request_policy_id   = lookup(behavior.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(behavior.value, "response_headers_policy_id", null)
      dynamic "function_association" {
        for_each = lookup(behavior.value, "function_arn", null) != null ? [true] : []
        content {
          event_type   = lookup(behavior.value, "function_event_type", "viewer-request")
          function_arn = behavior.value.function_arn
        }
      }
    }
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.restriction_locations
    }
  }

  tags = local.tags
}
