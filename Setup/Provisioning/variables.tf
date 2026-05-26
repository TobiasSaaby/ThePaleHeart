variable "servers" {
  type = map(object({
    ip   = string
    role = string
  }))

  default = {
    k3s-srv-1 = { ip = "10.10.1.10", role = "server" }
    k3s-srv-2 = { ip = "10.10.1.11", role = "server" }
    k3s-srv-3 = { ip = "10.10.1.12", role = "server" }
  }
}

variable "location" {
  type    = string
  default = "hel1"
}

variable "k3s_server_type" {
  type    = string
  default = "cx33"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
