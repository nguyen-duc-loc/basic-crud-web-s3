output "webs_public_ips" {
  value = [for instance in module.webs_ec2 : "${instance.instance_id}: ${instance.public_ip}"]
}
