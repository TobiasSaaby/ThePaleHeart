resource "hcloud_server" "development_vps" {
  count = var.development_vps.enabled ? 1 : 0

  name        = var.development_vps.name
  image       = var.development_vps.image
  server_type = var.development_vps.server_type
  location    = var.location

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]

  network {
    network_id = hcloud_network.k3s_net.id
    ip         = var.development_vps.private_ip
  }

  labels = {
    role    = "development"
    service = "hermes"
    os      = "nixos"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_firewall" "development_vps" {
  count = var.development_vps.enabled ? 1 : 0

  name = "${var.development_vps.name}-firewall"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.development_vps.ssh_source_ips
  }
}

resource "hcloud_firewall_attachment" "development_vps" {
  count = var.development_vps.enabled ? 1 : 0

  firewall_id = hcloud_firewall.development_vps[0].id
  server_ids  = [hcloud_server.development_vps[0].id]
}
