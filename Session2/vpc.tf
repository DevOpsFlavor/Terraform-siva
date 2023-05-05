resource "aws_vpc" "main" { # this name belongs to only terraform
      cidr_block       = "10.0.0.0/16"
      instance_tenancy = "default"
    
      tags = {
        Name = "automated-vpc" # this name belongs to AWS
      }

}
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id #it will fetch vpc id from above code
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet-automated-vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id #it will fetch vpc id from above code
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet-automated-vpc"
  }
}

resource "aws_internet_gateway" "automated-igw" {
  vpc_id = aws_vpc.main.id #internet gateway depends on VPC

  tags = {
    Name = "automated-igw"
  }
}


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.automated-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}
#private route table is depends on NAT
# NAT depends on  elastic IP

resource "aws_eip" "auto_eip" {
    tags = {
        Name = "auto_eip"
    }
 
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.auto_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "automated-NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.automated-igw]
}


resource "aws_route_table" "private-rt" { #for private route we don't attach IGW, We attached NAT gateway
  vpc_id = aws_vpc.main.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }


   tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private-rt.id
}