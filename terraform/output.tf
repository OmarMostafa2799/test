output "vpc_id" {
  value = aws_vpc.k8s_vpc.id
}

output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "master_private_ip" {
  value = aws_instance.master.private_ip
}

output "worker_private_ips" {
  value = aws_instance.workers[*].private_ip
}

output "worker_ids" {
  value = aws_instance.workers[*].id
}
