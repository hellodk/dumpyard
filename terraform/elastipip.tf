resource "aws_eip" "ip" {
  instance = aws_instance.demo.id
}