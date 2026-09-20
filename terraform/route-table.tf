resource "aws_route_table" "public" {
  vpc_id = aws_vpc.linux_hardening.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.linux_hardening.id
  }

  tags = {
    Name = "linux-hardening-public-rt"
  }
}
