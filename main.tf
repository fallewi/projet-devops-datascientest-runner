provider "aws" {
  region = "eu-west-3"
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "datascientest-project-runner-state"  # Remplacez par un nom unique pour le bucket
    key    = "runner.tfstate"
    region = "eu-west-3"

  acl    = "private"

  versioning {
    enabled = true  # Active la versioning des objets dans le bucket
  }
}

locals {
  tags = {
    Environment = var.environment
  }
}

###############################################################################
# VPC
###############################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name = "gitlab-runner-demo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = local.tags
}

###############################################################################
# Security Group
###############################################################################
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = "gitlab-runner-instance-sg"
  description = "Security group for gitlab-runner-instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-all"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}


###############################################################################
# Gitlab Runner
###############################################################################

module "runners" {
  source = "./modules/runners/"
  gitlab_runner_registration_token = var.gitlab_runner_registration_token
  security_group_id = module.security-group.security_group_id
  private_subnets = module.vpc.private_subnets[0]
}

module "statebucket" {
  source = "./modules/statebucket/"
}
