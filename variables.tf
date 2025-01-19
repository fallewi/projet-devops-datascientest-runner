###############################################################################
# Environment
###############################################################################
variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "aws_account_id" {
  type    = string
  default = "137893875086"
}

variable "environment" {
  type    = string
  default = "prod"
}

###############################################################################
# Gitlab Runner
###############################################################################
variable "gitlab_runner_registration_token" {
  type    = string
  default = null
}
