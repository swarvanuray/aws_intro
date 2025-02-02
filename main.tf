



data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  count         = 4
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.small"
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "HelloWorld-${count.index}"
    Team = "Beta"
  }
}


resource "aws_key_pair" "deployer" {
  
  key_name   = "${var.ssh_key_name}-${var.env}"
  public_key = tls_private_key.deployer.public_key_openssh
   provisioner "local-exec" {
    command = "mkdir -p ~/.ssh && echo '${tls_private_key.deployer.private_key_openssh}' > ~/.ssh/${self.key_name}.pem && chmod 400 ~/.ssh/${self.key_name}.pem"
  interpreter = ["bash", "-c"]

   }
   
}
data "aws_availability_zones" "available" {
  state = "available"
}
resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_custom_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_route_table_association" "public_crt_public_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_custom_route_table.id
}

