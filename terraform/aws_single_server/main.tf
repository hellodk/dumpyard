provider "aws" {
  version = "~> 2.17"
  region = var.region
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_instance" "demo_instance" {
  ami           = "ami-07d40e643a23a9813"
  key_name = aws_key_pair.demo_key_pair.key_name
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "<html>Good, Day</html>" > /home/ubuntu/index.html
              apt update -y
              apt install -y nginx
              systemctl enable nginx
              systemctl start nginx
              mv /home/ubuntu/index.html /var/www/html/index.nginx-debian.html 
              systemctl restart nginx
              EOF
  provisioner "local-exec" {
    command = "echo ${aws_instance.demo_instance.public_ip} >> public_ip.txt"
  }
  tags = {
    Name = "demo-machine"
    Owner = "Deepak"
    Team = "Level 1"
    Manager = "dk"
  }
}

resource "aws_eip" "demo_eip" {
  instance = aws_instance.demo_instance.id
    tags = {
    Name = "demo-eip"
    Owner = "Deepak"
    Team = "Level 1"
    Manager = "dk"
  }
}

resource "aws_security_group" "demo_sg" {
  vpc_id = aws_default_vpc.default.id
  name = "demo_instance_sg"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "demo_key_pair" {
  key_name   = "demo_key"
  public_key = ""
}