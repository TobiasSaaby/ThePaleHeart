resource "hcloud_network" "k3s_net" {
  name     = "k3s-network"
  ip_range = var.network_ip_range
}

resource "hcloud_network_subnet" "k3s_subnet" {
  network_id   = hcloud_network.k3s_net.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.network_subnet_ip_range
}
