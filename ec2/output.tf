output "instance_id" {
  value = aws_instance.ec2.id
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "private_dns" {
  value = aws_instance.ec2.private_dns
}

output "arn" {
  value = aws_instance.ec2.arn
}
