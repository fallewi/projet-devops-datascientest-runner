###############################################################################
# Provider
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

###############################################################################
# Data Source
###############################################################################
data "aws_ami" "latest_amazon_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


###############################################################################
# Locals
###############################################################################
locals {
  tags = {
    Environment = var.environment
  }
}


###############################################################################
# EC2
###############################################################################
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.1"

  name = "gitlab-runner"

  instance_type          = "t3.medium"
  vpc_security_group_ids = ["${var.security_group_id}"]
  subnet_id              = var.private_subnets
  ami                    = data.aws_ami.latest_amazon_linux_ami.id
  
  user_data = templatefile("./scripts/gitlab_runner_install.tpl", {
    gitlab_runner_registration_token = var.gitlab_runner_registration_token
  })

  tags = local.tags
}
