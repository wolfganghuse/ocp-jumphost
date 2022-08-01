terraform{
  required_providers{
    nutanix = {
      source = "nutanix/nutanix"
      version = "~> 1.3.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "nutanix" {
  username  = var.PC_USER
  password  = var.PC_PASS
  endpoint  = var.PC_ENDPOINT
  insecure  = true
  port      = 9440
}

variable "cloudflare_api_token" {
  type = string
}

variable "PC_PASS" {
  type = string
}

variable "OCP_API_VIP" {
  type = string
}

variable "OCP_INGRESS_VIP" {
  type = string
}

variable "OCP_BASEDOMAIN" {
  type = string
}

variable "OCP_SUBDOMAIN" {
  type = string
}

variable "PC_USER" {
  type = string
}

variable "PC_ENDPOINT" {
  type = string
}

variable "nutanix_subnet" {
  type = string
}

variable "nutanix_cluster" {
  type = string
}

variable "packer_source_image" {
  type = string
}

variable "installer_name" {
  type = string
}

data "nutanix_subnet" "net" {
  subnet_name = var.nutanix_subnet
}

data "nutanix_cluster" "cluster" {
  name = var.nutanix_cluster
}

data "template_file" "cred_string" {
  template = "[{\"type\":\"basic_auth\",\"data\":{\"prismCentral\":{\"username\":\"$${user}\",\"password\":\"$${pass}\"},\"prismElements\":null}}]"
    vars = {
      user = var.PC_USER
      pass = var.PC_PASS
  }
}

data "cloudflare_zone" "this" {
  name = "dachlab.net"
}

resource "cloudflare_record" "API" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("api.%s", var.OCP_SUBDOMAIN)
  value   = "10.38.59.11"
  type    = "A"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "INGRESS" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("*.apps.%s", var.OCP_SUBDOMAIN)
  value   = "10.38.59.12"
  type    = "A"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "PC" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("pc-%s", var.OCP_SUBDOMAIN)
  value   = var.PC_ENDPOINT
  type    = "A"
  ttl     = 3600
  proxied = false
}

resource "nutanix_image" "source_image" {
  source_uri = var.packer_source_image
  name = "ubuntu-20.04"
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

  guest_customization_cloud_init_user_data = base64encode(templatefile("./cloud-config.tftpl", {
    machine_name = var.installer_name
    ssh_key = file("~/.ssh/hpoc.pub")
  }))



  connection {
    user     = "ubuntu"  
    type     = "ssh"
    private_key = file("~/.ssh/hpoc")
    host    = self.nic_list_status[0].ip_endpoint_list[0].ip
  }

  provisioner "file" {
    content    = templatefile("./credentials.tftpl", {
    user = var.PC_USER
    password = var.PC_PASS
    })
    destination = "./credentials"
  }

  provisioner "file" {
    source      = "cert"
    destination = "."
  }
  
  provisioner "remote-exec" {
    script = "files/prereq.sh"
  }

  provisioner "file" {
    source      = "pullsecret/ps.json"
    destination = "/home/ubuntu/ipi/ps.json"
  }

  provisioner "file" {
    content    = templatefile("./openshift-machine-api-nutanix-credentials-credentials.tftpl", {
    credentials = base64encode(data.template_file.cred_string.rendered)
    })
    destination = "./ipi/openshift-machine-api-nutanix-credentials-credentials.yaml"
  }

  provisioner "file" {
    content    = templatefile("./install-config.tftpl", {
    user = var.PC_USER
    password = var.PC_PASS
    basedomain = var.OCP_BASEDOMAIN
    name = var.OCP_SUBDOMAIN
    apivip = var.OCP_API_VIP
    ingressvip = var.OCP_INGRESS_VIP
    address = format("pc-%s.%s",var.OCP_SUBDOMAIN,var.OCP_BASEDOMAIN)
    peip = data.nutanix_cluster.cluster.external_ip
    peuuid = data.nutanix_cluster.cluster.id
    subnetuuid = data.nutanix_subnet.net.id
    pullsecret = file("pullsecret/ps.json")
    })
    destination = "./ipi/install-config.yaml"
  }

  provisioner "file" {
    source      = "~/.ssh/hpoc"
    destination = "/home/ubuntu/.ssh/hpoc"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/hpoc",
      "sudo chmod 0600 /home/ubuntu/.ssh/hpoc"
    ]
  }

}

# Show IP address
output "ip_address" {
  value = nutanix_virtual_machine.installer.nic_list_status[0].ip_endpoint_list[0].ip
}
