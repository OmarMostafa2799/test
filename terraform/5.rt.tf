resource "aws_route_table" "master-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "master-rt-as" {
  subnet_id      = aws_subnet.master-subnet.id
  route_table_id = aws_route_table.master-rt.id
}




resource "aws_route_table" "worker-1-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

}

resource "aws_route_table_association" "woker-1-rt-as" {
  subnet_id      = aws_subnet.woker-1-subnet.id
  route_table_id = aws_route_table.worker-1-rt.id
}


resource "aws_route_table" "worker-2-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

}

resource "aws_route_table_association" "woker-2-rt-as" {
  subnet_id      = aws_subnet.woker-2-subnet.id
  route_table_id = aws_route_table.worker-2-rt.id
}

