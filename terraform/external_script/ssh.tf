resource "aws_security_group" "ssh" {
  name        = "${var.name}-ssh"
  description = "Allow connection by ssh"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_ip_address}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}",
  }
}

output "commandout" {
  value = "${var.command_output}"
}