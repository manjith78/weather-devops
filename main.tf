provider "null" {}

resource "null_resource" "devops" {
  provisioner "local-exec" {
    command = "echo Infrastructure Ready"
  }
}