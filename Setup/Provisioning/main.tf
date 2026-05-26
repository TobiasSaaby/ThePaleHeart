terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {}

resource "hcloud_ssh_key" "default" {
  name       = "main-key"
  public_key = file(var.ssh_public_key_path)
}
