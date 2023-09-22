

data "nutanix_image" "source_image" { 
  provider             = nutanix.AZ01
  image_name = "win2019"
}

data "nutanix_cluster" "cluster" {

  provider = nutanix.AZ01

  name = var.nutanix_cluster
}

data "nutanix_subnet" "net" {

  provider = nutanix.AZ01

  subnet_name = var.jumphost_nutanix_subnet

}

resource "nutanix_virtual_machine" "msad" {
  provider             = nutanix.AZ01

  name                 = "MSAD"
  num_vcpus_per_socket = 4
  num_sockets          = 1
  memory_size_mib      = 8192

  cluster_uuid = data.nutanix_cluster.cluster.id

  nic_list {
    subnet_uuid = data.nutanix_subnet.net.id
    ip_endpoint_list {
      ip   = var.msad_ip
      type = "ASSIGNED"
    }
  }

  disk_list {
    data_source_reference = {
        kind = "image"
        uuid = data.nutanix_image.source_image.id
      }
  
    device_properties {
      disk_address = {
        device_index = 0
        adapter_type = "SCSI"
      }

      device_type = "DISK"
    }
  }

  guest_customization_sysprep = {
    unattend_xml = base64encode(file("${path.module}/unattend.xml"))
  }


}