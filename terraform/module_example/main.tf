provider "aws" {
  version = "~> 2.17"
  region = var.region
}

module "multiple_instances" {
  source  = "../modules/multiple_instances"
  tags = "Nothing Serious, it's just a module"
  }