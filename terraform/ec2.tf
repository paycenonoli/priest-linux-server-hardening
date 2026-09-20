resource "aws_instance" "linux_hardening" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.linux_hardening.id]
  key_name = "keys-4-priest"
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}
