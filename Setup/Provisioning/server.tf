resource "hcloud_server" "vps" {
  for_each = var.servers

  name        = each.key
  image       = "ubuntu-24.04"
  server_type = var.k3s_server_type
  location    = var.location

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]

  network {
      network_id = hcloud_network.k3s_net.id
      ip         = each.value.ip
  }

  labels = {
    role = each.value.role
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
