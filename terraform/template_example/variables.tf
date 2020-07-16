variable "region" {
  default = "ap-south-1"
}

variable "ssh_key_name" {
  default = "demo_key_template"
}

variable "pub_key" {
    default = ""
}


variable "endpoints" {
  
type = "list"
  
default = [
    { endpoint1 = "https://endpoint-1.example.com" },
    { endpoint2 = "https://endpoint-2.example.com" },
    { endpoint3 = "https://endpoint-3.example.com" },
  ]
}