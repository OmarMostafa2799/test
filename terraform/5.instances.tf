
resource "aws_instance" "public-ec2" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet.id
  security_groups = [aws_security_group.sg.id]
  availability_zone = "us-east-1a"
  key_name = aws_key_pair.my-key.key_name

  tags = {
    Name = "PublicEC2Instance"
  }
}




resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = file("key.pub")  
}





# Generate inventory file for Ansible

# resource "local_file" "inventory" {
#   filename = "/ansible/inventory"
#   content  = <<EOT
# [private]
# ${aws_instance.private-ec2.private_ip}
#
# [public]
# ${aws_instance.public-ec2.public_ip}
# EOT
# }

