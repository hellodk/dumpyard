variable "region" {
  default = "ap-south-1"
}


output "ip" {
  value = aws_eip.demo_eip.public_ip
}

variable "server_port" {
  description = "The port the Nginx server will use for HTTP requests"
  type        = number
  default     = 80
}