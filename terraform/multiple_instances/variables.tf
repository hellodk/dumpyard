"ami" {
  type = "map"

  default = {
    "ap-south-1" = "ami-07d40e643a23a9813"
    "ap-southeast-1" = "ami-006fctol625b177f"
  }
}

variable "region" {
  default = "ap-south-1"
}

variable "subnet_id" {
  default = ""
}

variable "instance_count" {
  default = "2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "batch" {
  default = "5AM"
}

variable "name" {
  default = "terraform-multiple-servers"
}

variable "ssh_key_name" {
    default = "demo_key"
}

variable "pub_key" {
    default = ""
}
