provider "aws" {
  version = "~> 2.17"
  region = var.region
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
/*  tags = {
    Name  = "${var.name}-${count.index + 1}"
    Batch = var.batch
  }*/
    tags = {
    Name  = "${var.name}-${count.index + 1}",
    Batch = var.batch,
    tags = var.tags
  }
}