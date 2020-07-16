terraform {
  required_version = ">= 0.12, <= 0.12.13"
}

provider "aws" {
  version = "~> 2.17"
  region = var.region
}

# data "aws_availability_zones" "all" {}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_launch_configuration" "demo_lc" {
  image_id = "ami-07d40e643a23a9813"
  key_name = aws_key_pair.demo_key_pair.key_name
#  count         = "${var.instance_count}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.demo_instance_sg.id}"]
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

/*  tag = {
    Name = "demo-machine-${count.index + 1}"
    Owner = "Deepak"
    Team = "Level 1"
    Manager = "dk"
  }*/
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "demo_instance_sg" {
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
    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "demo_key_pair" {
  key_name   = "demo_key"
  public_key = ""
}

resource "aws_autoscaling_group" "demo_asg" {
  launch_configuration = "${aws_launch_configuration.demo_lc.id}"
#  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["ap-south-1a"]
  load_balancers    = ["${aws_elb.demo_elb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-demo_asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "demo_elb" {
  name               = ""
#  availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["ap-south-1a"]
  security_groups    = ["${aws_security_group.demo_elb_sg.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "demo_elb_sg" {
  name = "terraform_demo_elb_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
