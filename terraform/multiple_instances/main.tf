provider "aws" {
  version = "~> 2.17"
  region = var.region
}

data "aws_subnet" "selected" {
  id = "${var.subnet_id}"
  filters = {
     Environment = dev
  }
}

resource "aws_key_pair" "multiple-instances-key" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.pub_key}"
}

resource "aws_instance" "multiple-instances" {
  count         = "${var.instance_count}"
  ami           = "${lookup(var.ami,var.aws_region)}"
  instance_type = "${var.instance_type}"
  key_name   = "${var.ssh_key_name}"
  user_data     = "${file("configure.sh")}"
  tags = {
    Name  = "${var.name}-${count.index + 1}"
    Batch = var.batch
  }
}

provider "aws" {
  version = "~> 2.17"
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

data "aws_subnet_ids" "example" {
  vpc_id = "${var.vpc_id}"
}

data "aws_subnet" "example" {
  count = "${length(data.aws_subnet_ids.example.ids)}"
  id    = "${data.aws_subnet_ids.example.ids[count.index]}"
}

output "subnet_cidr_blocks" {
  value = ["${data.aws_subnet.example.*.cidr_block}"]
}

# count  = "${length(split(",", var.subnet_id)}"