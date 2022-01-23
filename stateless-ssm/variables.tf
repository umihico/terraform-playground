variable "secrets" {
  description = "secrets"
  default     = null
  type        = list(map(string))
}

variable "region" {
  description = "region"
  default     = null
  type        = string
}

variable "profile" {
  description = "value"
  default     = null
  type        = string
}

variable "STATELESS_SSM_PROFILE" {
  description = "You can use your personal profile name by doing something like 'TF_VAR_STATELESS_SSM_PROFILE=profile2 terraform apply'. This will overwrite var.profile"
  default     = "default"
  type        = string
}

variable "exec_log_suppresser" {
  # https://github.com/hashicorp/terraform/pull/26611
  type      = string
  default   = "foo"
  sensitive = true
}
