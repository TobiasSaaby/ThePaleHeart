output "ansible_inventory" {
  value = join("\n", concat(
    ["[k3s_servers]"],
    [
      for name, server in hcloud_server.vps :
      "${name} ansible_host=${server.ipv4_address} local_ip=${one(server.network[*].ip)}"
    ],
    [
      "",
      "[k3s_servers:vars]",
      "ansible_user=root",
      "ansible_ssh_private_key_file=~/.ssh/id_ed25519",
      "ansible_python_interpreter=/usr/bin/python3"
    ],
    [
      "",
      "[k3s_lb]",
      "api_lb ansible_host=${hcloud_load_balancer.k3s_api.ipv4}"
    ],
    var.development_vps.enabled ? [
      "",
      "[development]",
      "${hcloud_server.development_vps[0].name} ansible_host=${hcloud_server.development_vps[0].ipv4_address} local_ip=${one(hcloud_server.development_vps[0].network[*].ip)} nixos_host=${var.development_vps.nixos_host} nixos_disk=${var.development_vps.nixos_disk}",
      "",
      "[development:vars]",
      "ansible_user=root",
      "ansible_ssh_private_key_file=~/.ssh/id_ed25519",
      "ansible_python_interpreter=/usr/bin/python3",
      "nixos_flake_path=../../NixOS"
    ] : []
  ))
}

output "k3s_load_balancer_ipv4" {
  value = hcloud_load_balancer.k3s_api.ipv4
}

output "development_vps_ipv4" {
  value = try(hcloud_server.development_vps[0].ipv4_address, null)
}

output "development_vps_private_ip" {
  value = try(one(hcloud_server.development_vps[0].network[*].ip), null)
}
