data "template_file" "data_json" {
  
template = "${file("${path.module}/data.json.tmpl")}"
  
count    = "${length(var.endpoints)}"
  vars = {
    
endpoint = "${element(values(var.endpoints[count.index]), 0)}"
    
name = "${element(keys(var.endpoints[count.index]), 0)}"
  }
}

variable "links" {
type = "list"
  
default = [
    "link1",
    "link2",
    "link3",
  ]
}
data "template_file" "service_json" {
template = "${file("${path.module}/service.json.tmpl")}"
vars = {
  
value = "${join(",", data.template_file.data_json.*.rendered)}"
  
links = "${jsonencode(var.links)}"
}
}

output "json" {
  
value = "${data.template_file.service_json.rendered}"
}