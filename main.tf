terraform{
  required_providers{
    nutanix = {
      source = "nutanix/nutanix"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

data "nutanix_subnet" "net" {
  subnet_name = var.nutanix_subnet
}

data "nutanix_cluster" "cluster" {
  name = var.nutanix_cluster
}


data "cloudflare_zone" "this" {
  name = var.OCP_BASEDOMAIN
}

resource "cloudflare_record" "API" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("api.%s", var.OCP_SUBDOMAIN)
  value   = var.OCP_API_VIP
  type    = "A"
}

resource "cloudflare_record" "INGRESS" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("*.apps.%s", var.OCP_SUBDOMAIN)
  value   = var.OCP_INGRESS_VIP
  type    = "A"
}

resource "cloudflare_record" "PC" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("pc-%s", var.OCP_SUBDOMAIN)
  value   = var.PC_ENDPOINT
  type    = "A"
}

resource "nutanix_image" "source_image" {
  source_uri = var.JUMPHOST_IMAGE
  name = "ubuntu-20.04"
}

resource "local_file" "cert_file"{
    content      = acme_certificate.certificate.certificate_pem
    filename = format("./%s.crt",var.OCP_SUBDOMAIN )
}

resource "local_file" "key_file" {
    content      = acme_certificate.certificate.private_key_pem
    filename = format("./%s.key",var.OCP_SUBDOMAIN )
}

resource "local_file" "ca_file" {
    content      = acme_certificate.certificate.issuer_pem
    filename = format("./ca-%s.crt",var.OCP_SUBDOMAIN )
}

resource "nutanix_virtual_machine" "installer" {
  name                 = var.installer_name
  num_vcpus_per_socket = 4
  num_sockets          = 1
  memory_size_mib      = 8192

  cluster_uuid = data.nutanix_cluster.cluster.id

  nic_list {
    subnet_uuid = data.nutanix_subnet.net.id
  }

  disk_list {
    disk_size_mib   = 50000
    data_source_reference = {
        kind = "image"
        uuid = resource.nutanix_image.source_image.id
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
}

resource "null_resource" "bastion" {

  connection {
    user     = "ubuntu"  
    type     = "ssh"
    private_key = file(var.JUMPHOST_PRIVATE_SSH)
    host    = nutanix_virtual_machine.installer.nic_list_status[0].ip_endpoint_list[0].ip
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf ~/ipi",
      "mkdir ~/ipi"
    ]
  }

  provisioner "file" {
    content    = templatefile("./templates/credentials.tftpl", {
    user = var.PC_USER
    password = var.PC_PASS
    })
    destination = "./credentials"
  }

  provisioner "file" {
    content    = templatefile("./templates/certs.tftpl", {
    ocp_subdomain = var.OCP_SUBDOMAIN
    })
    destination = "./ipi/certs.sh"
  }

  provisioner "file" {
    source      = "files/"
    destination = "ipi"
  }

  provisioner "file" {
    content      = acme_certificate.certificate.certificate_pem
    destination = format("./ipi/%s.crt", var.OCP_SUBDOMAIN)
  }
  provisioner "file" {
    content      = acme_certificate.certificate.private_key_pem
    destination = format("./ipi/%s.key", var.OCP_SUBDOMAIN)
  }
    provisioner "file" {
    content      = acme_certificate.certificate.issuer_pem
    destination = "./ipi/ca.crt"
  }
  
  provisioner "remote-exec" {
    script = "scripts/prereq.sh"
  }

  provisioner "file" {
    content    = templatefile("./templates/openshift-machine-api-nutanix-credentials-credentials.tftpl", {
    credentials = base64encode(format("[{\"type\":\"basic_auth\",\"data\":{\"prismCentral\":{\"username\":\"%s\",\"password\":\"%s\"},\"prismElements\":null}}]",var.PC_USER,var.PC_PASS))
    })
    destination = "./ipi/openshift-machine-api-nutanix-credentials-credentials.yaml"
  }

  provisioner "file" {
    content    = templatefile("./templates/openshift-cloud-controller-manager-nutanix-credentials-credentials.tftpl", {
    credentials = base64encode(format("[{\"type\":\"basic_auth\",\"data\":{\"prismCentral\":{\"username\":\"%s\",\"password\":\"%s\"},\"prismElements\":null}}]",var.PC_USER,var.PC_PASS))
    })
    destination = "./ipi/openshift-cloud-controller-manager-nutanix-credentials-credentials.yaml"
  }

  provisioner "file" {
    content    = templatefile("./templates/.kubectl-karbon.tftpl", {
    user = var.PC_USER
    address = var.PC_ENDPOINT})
    destination = "./.kubectl-karbon.yaml"
  }

  provisioner "file" {
    content    = templatefile("./templates/install-config.tftpl", {
    user = var.PC_USER
    password = var.PC_PASS
    basedomain = var.OCP_BASEDOMAIN
    name = var.OCP_SUBDOMAIN
    apivip = var.OCP_API_VIP
    ingressvip = var.OCP_INGRESS_VIP
    address = format("pc-%s.%s",var.OCP_SUBDOMAIN,var.OCP_BASEDOMAIN)
    machinecidr = format("%s/%s",data.nutanix_subnet.net.subnet_ip,data.nutanix_subnet.net.prefix_length)
    peip = data.nutanix_cluster.cluster.external_ip
    peuuid = data.nutanix_cluster.cluster.id
    subnetuuid = data.nutanix_subnet.net.id
    pullsecret = file("files/ps.json")
    ssh = file(var.JUMPHOST_PUBLIC_SSH)
    })
    destination = "./ipi/install-config.yaml"
  }

  provisioner "file" {
    content    = templatefile("./templates/csi.tftpl", {
    user = var.PE_USER
    password = var.PE_PASS
    endpoint = data.nutanix_cluster.cluster.external_ip
    container = var.CONTAINER
    })
    destination = "./ipi/csi.sh"
  }

  provisioner "file" {
    source      = var.JUMPHOST_PRIVATE_SSH
    destination = "/home/ubuntu/.ssh/remote"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/remote",
      "sudo chmod 0755 /home/ubuntu/ipi/*.sh",
      "sudo chmod 0600 /home/ubuntu/.ssh/remote"
    ]
  }

}
