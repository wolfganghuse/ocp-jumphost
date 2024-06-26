locals {
  config_folder = var.subdomain
  controlplane_cpu = "${var.controlplane_size == "large" ? 8 : 4}"
  controlplane_mem = "${var.controlplane_size == "large" ? 32768 : 16384}"
  worker_count = "${var.cluster_role == "hub" ? 3 : 2}"
  worker_cpu = "${var.cluster_role == "hub" ? 8 : 2}"
  worker_mem = "${var.cluster_role == "hub" ? 16384 : 8192}"
  ocpbasedomain = format("%s.%s.%s", var.subdomain, var.zone,var.basedomain)
  pc = "${var.PC_ENDPOINT_EXISTING_FQDN == "" ? var.PC_ENDPOINT : var.PC_ENDPOINT_EXISTING_FQDN}"
}

module "cert_ocp" {
  source              = "../ssl"
  
  ZONE_ID = var.ZONE_ID
  common_name = local.ocpbasedomain
  subject_alternative_names = [
    format("api.%s", local.ocpbasedomain),
    format("*.apps.%s", local.ocpbasedomain)
  ]
}

data "nutanix_subnet" "net" {
  subnet_name = var.subnet
}

data "nutanix_cluster" "cluster" {
  name = var.cluster
}

resource "aws_route53_record" "API" {
  zone_id = var.ZONE_ID
  name    = format("api.%s.%s", var.subdomain, var.zone)
  type    = "A"
  ttl     = 300
  records = [var.api_vip]
}

resource "aws_route53_record" "API-int" {
  zone_id = var.ZONE_ID
  name    = format("api-int.%s.%s", var.subdomain, var.zone)
  type    = "A"
  ttl     = 300
  records = [var.api_vip]
}

resource "aws_route53_record" "INGRESS" {
  zone_id = var.ZONE_ID
  name    = format("*.apps.%s.%s", var.subdomain, var.zone)
  type    = "A"
  ttl     = 300
  records = [var.ingress_vip]
}

resource "null_resource" "installer" {

  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    user     = var.user  
    type     = "ssh"
    private_key = file(var.ssh_priv)
    host    = var.bastion_fqdn
  }

  provisioner "remote-exec" {
    inline = [
      format("rm -rf ~/%s",local.config_folder),
      format("mkdir ~/%s",local.config_folder)
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/"
    destination = local.config_folder
  }

  provisioner "file" {
    content      = module.cert_ocp.certificate_pem
    destination = format("./%s/%s.crt", local.config_folder, var.subdomain)
  }
  provisioner "file" {
    content      = module.cert_ocp.private_key_pem
    destination = format("./%s/%s.key", local.config_folder, var.subdomain)
  }
  provisioner "file" {
    content      = module.cert_ocp.issuer_pem
    destination = format("./%s/ca.crt", local.config_folder)
  }
  
  provisioner "file" {
    content    = templatefile("${path.module}/templates/openshift-machine-api-nutanix-credentials-credentials.tftpl", {
    credentials = base64encode(format("[{\"type\":\"basic_auth\",\"data\":{\"prismCentral\":{\"username\":\"%s\",\"password\":\"%s\"},\"prismElements\":null}}]",var.PC_USER,var.PC_PASS))
    })
    destination = format("./%s/openshift-machine-api-nutanix-credentials-credentials.yaml", local.config_folder)
  }

  provisioner "file" {
    content    = templatefile("${path.module}/templates/openshift-cloud-controller-manager-nutanix-credentials-credentials.tftpl", {
    credentials = base64encode(format("[{\"type\":\"basic_auth\",\"data\":{\"prismCentral\":{\"username\":\"%s\",\"password\":\"%s\"},\"prismElements\":null}}]",var.PC_USER,var.PC_PASS))
    })
    destination = format("./%s/openshift-cloud-controller-manager-nutanix-credentials-credentials.yaml", local.config_folder)
  }

  provisioner "file" {
    content    = templatefile("${path.module}/templates/install-config.tftpl", {
    user = var.PC_USER
    password = var.PC_PASS
    controlplane_cpu = local.controlplane_cpu
    controlplane_mem = local.controlplane_mem
    worker_cpu = local.worker_cpu
    worker_mem = local.worker_mem
    worker_count = local.worker_count
    basedomain = format("%s.%s",var.zone,var.basedomain)
    name = var.subdomain
    apivip = var.api_vip
    ingressvip = var.ingress_vip
    address = local.pc
    peip = data.nutanix_cluster.cluster.external_ip
    peuuid = data.nutanix_cluster.cluster.id
    subnetuuid = data.nutanix_subnet.net.id
    machinecidr = format("%s/%s",data.nutanix_subnet.net.subnet_ip,data.nutanix_subnet.net.prefix_length)
    pullsecret = var.mirror ? templatefile("${path.module}/templates/ps.tftpl", {
      mirror = var.mirror_host
      mirror_repo = var.mirror_repo
    }) : var.pullsecret
    appends = var.mirror ? templatefile("${path.module}/templates/install-config-appends.tftpl", {
        ca = indent(2,module.cert_ocp.issuer_pem)
        mirror = var.mirror_host
        mirror_repo = var.mirror_repo
    }) : ""
    ssh = file(var.ssh_pub)
    })
    
    destination = format("./%s/install-config.yaml", local.config_folder)
  }

  provisioner "file" {
    content    = templatefile("${path.module}/templates/infranodes.tftpl", {
    cpu = local.controlplane_cpu
    mem = local.controlplane_mem
    })
    
    destination = format("./%s/infranodes.sh", local.config_folder)
  }

  provisioner "file" {
    content    = templatefile("${path.module}/templates/certs.tftpl", {
    ocp_subdomain = var.subdomain
    mirror = var.mirror_host
    })
    destination = format("./%s/certs.sh", local.config_folder)
  }
  
  provisioner "file" {
    content    = templatefile("${path.module}/templates/create_ocp.tftpl", {
    additionalCommands = "${var.cluster_role == "hub" ? "" : "sh infranodes.sh"}"
    proxy_cache = "${var.PROXY_CACHE ? "sh proxy-cache.sh" : ""}"
    hybridnetwork = "${var.cluster_role == "windows" ? "cp cluster-network-03-config.yaml manifests" : ""}"
    mirrorCommands = "${var.mirror ? "sh disconnect.sh" : ""}"
    })
    destination = format("./%s/create_ocp.sh", local.config_folder)
  }
  provisioner "remote-exec" {
    inline = [
      format("chmod +x ./%s/*.sh", local.config_folder)
    ]
  }

  provisioner "remote-exec" {
    inline = [
      format("cp ./%s/install-config.yaml ./%s/install-config.yaml.x", local.config_folder, local.config_folder)
    ]
  }
}

resource "null_resource" "bastion_disconnected" {
  count = var.mirror ? 1 : 0

  depends_on = [ null_resource.installer ]
  
  connection {
    user     = var.user
    type     = "ssh"
    private_key = file(var.ssh_priv)
    host    = var.bastion_fqdn
  }
  
  provisioner "file" {
    content    = templatefile("${path.module}/templates/disconnected.tftpl", {
    mirror = var.mirror_host
    mirror_repo = var.mirror_repo
    ocp_ver = var.ocp_ver
    })
    destination = format("./%s/disconnected.sh", local.config_folder)
  }

}


