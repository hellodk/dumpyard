data "external" "example" {
  program = ["sh", "test.sh" ]
}

module "aws" {
  source = "./modules/aws"

  ssh_ip_address = "${data.external.example.result.ip}"

  command_output = "${data.external.example.result}"
}