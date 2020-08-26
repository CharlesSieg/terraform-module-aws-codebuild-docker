variable "app_name" {
  description = "The app name used for tagging infrastructure."
  type        = string
}

variable "aws_region" {
  description = "The AWS region in which the infrastructure will be provisioned."
  type        = string
}

variable "cluster_name" {
  description = ""
  type        = string
}

variable "environment" {
  description = "The environment in which this infrastructure will be provisioned."
  type        = string
}

variable "github_repo_url" {
  description = ""
  type        = string
}

variable "image_repo_name" {
  description = ""
  type        = string
}

variable "service_name" {
  description = ""
  type        = string
}

variable "target_account_id" {
  description = ""
  type        = string
}

