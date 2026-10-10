
resource "aws_instance" "master" {
  ami           = "ami-0056d98d3e05cdbd9"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public-subnet.id
  private_ip    = "10.0.1.10"
  security_groups = [aws_security_group.cluster.id]
  availability_zone = "eu-west-1a"
  associate_public_ip_address = true
 # user_data = "${file("script.sh")}"
  key_name = aws_key_pair.my-key.key_name

  tags = {
    Name = "Master-Node"
  }
}


resource "aws_instance" "workers" {
  count         = 2
  ami           = "ami-0056d98d3e05cdbd9"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private-subnet.id
  security_groups = [aws_security_group.cluster.id]
  availability_zone = "eu-west-1a"
  key_name = aws_key_pair.my-key.key_name

  tags = {
    Name = "Worker-${count.index + 1}"
  }
}



resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = file("key.pub")
}





# Generate inventory file for Ansible

resource "local_file" "inventory" {
  filename = "../ansible/inventory"

  content = <<-EOT
 [master]
 ${aws_instance.master.public_ip}

 [workers]
 %{for worker in aws_instance.workers~}
 ${worker.private_ip}
 %{endfor~}

EOT
}
