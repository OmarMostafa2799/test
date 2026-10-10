resource "aws_subnet" "master-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch= "true"
  availability_zone = "eu-west-1a"

}

resource "aws_subnet" "worker-1-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

}

resource "aws_subnet" "worker-2-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-1a"

}
