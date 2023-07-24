# resource "nutanix_image" "source_image" {

#   provider = nutanix.AZ01

#   source_uri = var.JUMPHOST_IMAGE
#   name = "ubuntu-22.10"
# }


data "nutanix_image" "source_image" {

  provider = nutanix.AZ01
  image_name = var.JUMPHOST_IMAGE

}