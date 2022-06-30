variable "primary_hosted_zone" {
  description = "Name of the primary hosted zone for DNS. e.g. primary_hosted_zone = example.org --> service.example.org."
  type        = string
}

# One of these is required.
variable "origins" {
  description = "One or more origins for this distribution. Must be defined unless s3_origins or custom_origins are defined. If defined, s3_origins and custom_origins must be empty."
  type        = list(any)
  default     = []
}

variable "s3_origins" {
  description = "One or more S3 origins for this distribution. Only necessary if combining with custom_origins. If defined, origins must be empty."
  type        = list(any)
  default     = []
}

variable "custom_origins" {
  description = "One or more custom origins for this distribution. Only necessary if combining with s3_origins. If defined, origins must be empty."
  type        = list(any)
  default     = []
}
