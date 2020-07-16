terraform {
  required_version = ">= 0.12, <= 0.12.13"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_db_instance" "demo_db_instance_1" {
  identifier_prefix   = "demo-db"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "demo_database"
  username            = "admin"
  # How should we set the password?
#  password            = "???"
  password            = "${var.db_password}"
}

