#Get latest amazon linux2023 AMI
data "aws_ami" "amazon_linux" {

  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


#create VPC
resource "aws_vpc" "main_vpc" {

  cidr_block = var.vpc_cidr
  tags = {
    Name = "main-vpc"
  }
}

#create public subnet
resource "aws_subnet" "public_subnet" {

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

#Create Internet Gateway

resource "aws_internet_gateway" "iqw" {

  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }

}

#create route table

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iqw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

#Associate route table

resource "aws_route_table_association" "rta" {

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

#create security group

resource "aws_security_group" "web_sg" {

  name = "web-security-group"

  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name = "web-sg"
  }
}

# Create Key Pair

resource "aws_key_pair" "terraform_key" {

  key_name = var.key_name

  public_key = file(var.public_key_path)
}

# Create EC2 Instance

resource "aws_instance" "web_server" {

  ami = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  key_name = aws_key_pair.terraform_key.key_name

  associate_public_ip_address = true

  user_data = file("userdata.sh")

  tags = {

    Name = var.server_name
  }
}