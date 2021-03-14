module "nodes" {
  source = "git::https://github.com/squat/hetzner-cloud-flatcar-linux.git?ref=ce10e88dfe0ae3ba60f3562b69f8ae2a006e9b79"
  count  = var.node_count

  name = "${var.cluster_name}-${count.index}"

  # Hetzner
  datacenter  = var.datacenter
  server_type = var.server_type
  os_image    = var.os_image

  # Configuration
  ssh_keys = concat([tls_private_key.ssh.public_key_openssh], var.ssh_keys)
  snippets = [data.template_file.worker-config[count.index].rendered]
}

data "template_file" "worker-config" {
  count    = var.node_count
  template = file("${path.module}/cl/worker.yaml")

  vars = {
    name         = "${var.cluster_name}-${count.index}"
    api          = var.api
    token        = var.token
    ca_cert_hash = var.ca_cert_hash
    release      = var.release_version
    version      = var.kubernetes_version
  }
}

resource "hcloud_server_network" "network" {
  count     = var.node_count
  server_id = module.nodes[count.index].id
  subnet_id = var.subnet_id
  ip        = cidrhost(split("-", var.subnet_id)[1], count.index + 2)
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Join the nodes to the cluster only once the private
# network has been attached.
resource "null_resource" "join" {
  count      = var.node_count
  depends_on = [hcloud_server_network.network]

  connection {
    private_key = tls_private_key.ssh.private_key_pem
    host        = module.nodes[count.index].ip.ipv4
    user        = "core"
    timeout     = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart systemd-networkd",
      "sudo systemctl start kubeadm-join",
    ]
  }
}
