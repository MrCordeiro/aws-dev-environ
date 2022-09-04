# =====================
#         VPC
# =====================
resource "aws_vpc" "dev_environ_vpc" {
  # This CIDR block determines the range of IP addresses allocated for your apps in the VPC.
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "dev_environ_subnet" {
  vpc_id                  = aws_vpc.dev_environ_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "dev_environ_internet_gateway" {
  vpc_id = aws_vpc.dev_environ_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "dev_environ_public_rt" {
  vpc_id = aws_vpc.dev_environ_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.dev_environ_public_rt.id
  # Any inbound traffic will be routed to this route table
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_environ_internet_gateway.id
}

resource "aws_route_table_association" "dev_environ_public_assoc" {
  subnet_id      = aws_subnet.dev_environ_subnet.id
  route_table_id = aws_route_table.dev_environ_public_rt.id
}

resource "aws_security_group" "dev_environ_sg" {
  # Because the security group has a name attribute, we don't need to add a name tag here.
  name        = "dev-sg"
  description = "dev environment security group"
  vpc_id      = aws_vpc.dev_environ_vpc.id

  ingress {
    description = "Only your own manchine can access"
    from_port   = 0
    to_port     = 0
    # Terraform needs negative numbers in quoters in order to honor the hiphen symbol.
    # -1 means all protocols are allowed.
    protocol    = "-1"
    cidr_blocks = ["${var.host_ip}/32"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# =====================
#         SSH
# =====================
resource "aws_key_pair" "dev_environ_auth" {
  key_name   = "dev-environ-key"
  public_key = file("~/.ssh/aws_dev_environ.pub")
}


# =====================
#         AWS EC2
# =====================
resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.dev_environ_auth.key_name
  vpc_security_group_ids = [aws_security_group.dev_environ_sg.id]
  subnet_id              = aws_subnet.dev_environ_subnet.id
  # Used to bootstrap the instance.
  user_data = file("templates/userdata.tpl")
  provisioner "local-exec" {
    command = templatefile("templates/${var.host_os}-ssh-config.tpl", {
      hostname      = self.public_ip,
      user          = "ubuntu",
      indentityfile = "~/.ssh/aws_dev_environ"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }


}
