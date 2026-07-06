variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "aemet-etl"
}
