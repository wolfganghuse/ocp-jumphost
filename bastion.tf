data "nutanix_subnet" "net" {

  provider = nutanix.AZ01

  subnet_name = var.nutanix_subnet
}

data "nutanix_subnet" "jumphost_net" {

  provider = nutanix.AZ01

  subnet_name = var.jumphost_nutanix_subnet

}

data "nutanix_cluster" "cluster" {

  provider = nutanix.AZ01

  name = var.nutanix_cluster
}

resource "nutanix_virtual_machine" "installer" {

  provider = nutanix.AZ01

  name                 = var.installer_name
  num_vcpus_per_socket = 4
  num_sockets          = 1
  memory_size_mib      = 8192

  cluster_uuid = data.nutanix_cluster.cluster.id

  nic_list {
    subnet_uuid = data.nutanix_subnet.jumphost_net.id
  }

  disk_list {
    disk_size_mib   = 50000
    data_source_reference = {
        kind = "image"
        uuid = data.nutanix_image.source_image.id
        //uuid = resource.nutanix_image.source_image.id
      }
  
    device_properties {
      disk_address = {
        device_index = 0
        adapter_type = "SCSI"
      }

      device_type = "DISK"
    }
  }


  guest_customization_cloud_init_user_data = base64encode(templatefile("./templates/cloud-config.tftpl", {
    machine_name = var.installer_name
    ssh_key = file(var.JUMPHOST_PUBLIC_SSH)
  }))

  connection {
    user     = "ubuntu"  
    type     = "ssh"
    private_key = file(var.JUMPHOST_PRIVATE_SSH)
    host    = nutanix_virtual_machine.installer.nic_list_status[0].ip_endpoint_list[0].ip
    //host    = "10.48.38.98"
  }

  provisioner "file" {
    content      = acme_certificate.bastion.certificate_pem
    destination = "cert.crt"
  }
  provisioner "file" {
    content      = acme_certificate.bastion.private_key_pem
    destination = "cert.key"
  }
    provisioner "file" {
    content      = acme_certificate.bastion.issuer_pem
    destination = "ca.crt"
  }

  provisioner "file" {
    content      = templatefile("./templates/bastion.tftpl", {
    ocp_basedir = var.ocp_basedir
    })
    destination = "bastion.sh"
  }

  provisioner "file" {
    content      = templatefile("./templates/.env.tftpl", {
    PE_HOST=data.nutanix_cluster.cluster.external_ip
    PE_PORT="9440"
    PE_PASSWORD=var.PE_PASS
    PE_USERNAME=var.PE_USER
    NUTANIX_PASSWORD=var.PC_PASS
    NUTANIX_USERNAME=var.PC_USER
    NUTANIX_ENDPOINT=var.PC_ENDPOINT
    NUTANIX_SUBNET=var.nutanix_subnet
    NUTANIX_CLUSTER=var.nutanix_cluster
    CSI_BETA=var.CSI_BETA
    })
    destination = ".env"
  }
  provisioner "remote-exec" {
    inline = ["sh bastion.sh"]
  }

  provisioner "file" {
    source      = var.JUMPHOST_PRIVATE_SSH
    destination = "/home/ubuntu/.ssh/remote"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/remote",
      "sudo chmod 0600 /home/ubuntu/.ssh/remote"
    ]
  }
}