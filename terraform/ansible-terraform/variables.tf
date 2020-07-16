variable "aws_region" {
    default = "ap-south-1"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "instance_name" {
    default = "terra-ansible"
}
variable "ami_id" {
    # default = "ami-07d40e643a23a9813"
    default = "ami-010428e3bf57e1ea1"
}
variable "ssh_user_name" {
    default = "ubuntu"
}
variable "ssh_key_name" {
    default = "demo_key"
}
variable "ssh_key_path" {
    default = "~/.ssh/id_rsa"
}
variable "subnets_cidr" {
	type = "list"
	#default = ["172.31.0.0/20", "172.31.0.0/20"]
    default = ["172.31.0.0/20"]
}
variable "instance_count" {
    default = 1
}
variable "dev_host_label" {
    default = "terra_ansible_host"
}

variable "pub_key" {
    default = ""
}