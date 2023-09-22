packer {
  required_version = ">= 1.7.8"
  required_plugins {
    nutanix = {
      version = ">= 0.3.1"
      source  = "github.com/nutanix-cloud-native/nutanix"
    }
  }
}

source "nutanix" "windows" {
  nutanix_username = var.nutanix_username
  nutanix_password = var.nutanix_password
  nutanix_endpoint = var.nutanix_endpoint
  nutanix_insecure = var.nutanix_insecure
  cluster_name     = var.nutanix_cluster
  
  vm_disks {
      image_type = "ISO_IMAGE"
      source_image_uri =  var.windows_source_uri
  }

  vm_disks {
      image_type = "ISO_IMAGE"
      source_image_uri = var.virtio_source_uri
  }

  vm_disks {
      image_type = "DISK"
      disk_size_gb = 100
  }

  vm_nics {
    subnet_name       = var.nutanix_subnet
  }
  
  cd_files         = ["image-build-packer/autounattend.xml", "image-build-packer/sysprep.bat"]
  
  shutdown_command = "F:/sysprep.bat"
  image_name        ="win2019"
  force_deregister  = true
  shutdown_timeout  = "13m"
  cpu               = 4
  os_type           = "Windows"
  memory_mb         = "8192"
  communicator      = "winrm"
  winrm_port        = 5986
  winrm_insecure    = true
  winrm_use_ssl     = true
  winrm_timeout     = "45m"
  winrm_password    = var.administrator_password
  winrm_username    = var.administrator_username
}

build {
  name = "win2019"

  sources = [
    "source.nutanix.windows"
  ]

}