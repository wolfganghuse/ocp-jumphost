terraform{
  required_providers{
    nutanix = {
      source = "nutanix/nutanix"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
} 