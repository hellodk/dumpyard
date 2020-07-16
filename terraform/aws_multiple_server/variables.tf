variable "region" {
  default = "ap-south-1"
}

output "elb_dns_name" {
  value = "${aws_elb.demo_elb.dns_name}"
}

variable "server_port" {
  description = "The port the Nginx server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "instance_count" {
  default = 0
}