resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.linux_hardening.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "linux-hardening-public-subnet"
  }
}
