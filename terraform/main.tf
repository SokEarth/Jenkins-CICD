provider "aws" {
 access_key = var.aws_access_key
 secret_key = var.aws_secret_key
 region     = var.aws_region
}

resource "aws_vpc" "prod-vpc" {
  cidr_block = "178.40.0.0/16"
  tags = {
    Name = "prod-vpc"
   }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "178.40.0.0/20"
  availability_zone = var.availability_zone

  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TCP"
    from_port        = 8000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# resource "aws_network_interface" "web-server-nic" {
#   subnet_id       = aws_subnet.subnet-1.id
#   private_ips     = ["178.40.0.0"]
#   security_groups = [aws_security_group.allow_web.id]
# }

# resource "aws_eip" "one" {
#   domain                    = "vpc"
#   network_interface         = aws_network_interface.web-server-nic.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on = [ aws_internet_gateway.gw, aws_instance.web_server ]
# }

resource "aws_instance" "ansible_server" {
  ami = var.ami_id
  subnet_id = aws_subnet.subnet-1.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  availability_zone = var.availability_zone
  key_name = var.key_name
  security_groups = [aws_security_group.allow_web.id]
  # network_interface {
  #   device_index = 0
  #   network_interface_id = aws_network_interface.web-server-nic.id
  # }
  tags = {
    Name = "ansible-server"
  }
}

resource "aws_instance" "jenkins_server" {
  ami = var.ami_id
  subnet_id = aws_subnet.subnet-1.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  availability_zone = var.availability_zone
  key_name = var.key_name
  security_groups = [aws_security_group.allow_web.id]
  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_instance" "k8_bootstrap_server" {
  ami = var.ami_id
  subnet_id = aws_subnet.subnet-1.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  availability_zone = var.availability_zone
  key_name = var.key_name
  security_groups = [aws_security_group.allow_web.id]
  tags = {
    Name = "k8_bootstrap_server"
  }
}

# output "server-public-ip" {
#   value = aws_eip.one.public_ip
# }