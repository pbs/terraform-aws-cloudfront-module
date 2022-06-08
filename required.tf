variable "primary_hosted_zone" {
  description = "Name of the primary hosted zone for DNS. e.g. primary_hosted_zone = example.org --> service.example.org."
  type        = string
}

variable "origins" {
  description = "One or more origins for this distribution."
  type        = list(any)
}
