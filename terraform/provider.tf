terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.66"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.1"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"   # relative to hetzner-vps/ thanks to -chdir
}

provider "hcloud" {
  token = data.sops_file.secrets.data["hcloud_token"]
}
