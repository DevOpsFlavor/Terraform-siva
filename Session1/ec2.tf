resource "aws_instance" "web" {
  ami           = "ami-03c7d01cf4dedc891"
  instance_type = "t2.micro"

}