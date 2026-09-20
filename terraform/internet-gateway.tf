resource "aws_internet_gateway" "linux_hardening" {
  vpc_id = aws_vpc.linux_hardening.id

  tags = {
    Name = "linux-hardening-igw"
  }
}
