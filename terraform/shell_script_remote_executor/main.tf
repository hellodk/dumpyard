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

  connection {
    type = "ssh"
    host = "${aws_instance.demo_instance.public_ip}"
    user = "ubuntu"
    port = 22
    agent = true
    #private_key = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
      connection {
    type = "ssh"
    host = "${aws_instance.demo_instance.public_ip}"
    user = "ubuntu"
    port = 22
    agent = true
    #private_key = "~/.ssh/id_rsa"
  }
    inline = [
      "echo '<html>Good, Day</html>' > /home/ubuntu/index.html",
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo mv /home/ubuntu/index.html /var/www/html/index.nginx-debian.html ",
      "sudo systemctl restart nginx",
    ]
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
  key_name   = "demo_ansible_key"
  public_key = ""
}