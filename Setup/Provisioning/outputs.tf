output "server_ips" {
  value = {
    for name, server in hcloud_server.vps :
    name => server.ipv4_address
  }
}
