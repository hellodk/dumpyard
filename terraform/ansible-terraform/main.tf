provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "myInstanceAWS" {
  count = "${length(var.subnets_cidr)}"
  instance_type = "${var.instance_type}"
  ami = "${var.ami_id}"
  key_name = "${var.ssh_key_name}"
  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_key_pair" "demo_key_pair" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.pub_key}"
}

resource "null_resource" "ConfigureAnsibleLabelVariable" {
  provisioner "local-exec" {
    command = "echo [${var.dev_host_label}:vars] > hosts"
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_user=${var.ssh_user_name} >> hosts"
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_private_key_file=${var.ssh_key_path} >> hosts"
  }
  provisioner "local-exec" {
    command = "echo [${var.dev_host_label}] >> hosts"
  }
}

resource "null_resource" "ProvisionRemoteHostsIpToAnsibleHosts" {
  count = "${var.instance_count}"
  connection {
    type = "ssh"
    user = "${var.ssh_user_name}"
    host = "${element(aws_instance.myInstanceAWS.*.public_ip, count.index)}"
    private_key = "${file("${var.ssh_key_path}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt upgrade -y",
      "sudo apt update -y",
      "sudo apt install python-setuptools python-pip -y",
      "sudo pip install flask"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${element(aws_instance.myInstanceAWS.*.public_ip, count.index)} >> hosts"
  }
}

resource "null_resource" "ModifyApplyAnsiblePlayBook" {
  
  provisioner "local-exec" {
    command = "sed -i -e '/hosts:/ s/: .*/: ${var.dev_host_label}/' play.yml"   #change host label in playbook dynamically
  }

  provisioner "local-exec" {
    command = "sleep 10; ansible-playbook -i hosts play.yml"
  }
  
  depends_on = ["null_resource.ProvisionRemoteHostsIpToAnsibleHosts"]
}
