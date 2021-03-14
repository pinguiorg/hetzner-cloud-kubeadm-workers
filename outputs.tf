output "ips" {
  value = {
    for n in module.nodes :
    n.name => n.ip
  }
}
