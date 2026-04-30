resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-clc15-tf"
    CC  = "1234567"
    Owner = "DevOps"
  }
}

resource "aws_subnet" "subnet_public_1a" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-public-tf-1a"
  }
}

resource "aws_subnet" "subnet_private_1a" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-private-tf-1a"
  }
}

resource "aws_subnet" "subnet_public_1b" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-public-tf-1b"
  }
}

resource "aws_subnet" "subnet_private_1b" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-private-tf-1b"
  }
}


resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "igw-vpc-tf"
  }
}


resource "aws_route_table" "tf_rt_public" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }
  tags = {
    Name = "rt-public-tf"
  }
}


resource "aws_route_table_association" "subnet_public_1a_associ" {
  subnet_id      = aws_subnet.subnet_public_1a.id
  route_table_id = aws_route_table.tf_rt_public.id
}

resource "aws_route_table_association" "subnet_public_1b_associ" {
  subnet_id      = aws_subnet.subnet_public_1b.id
  route_table_id = aws_route_table.tf_rt_public.id
}


resource "aws_eip" "eip_tf_1a" {
  domain   = "vpc"
  tags = {
    Name = "eip-public-tf-1a"
  }
}

resource "aws_eip" "eip_tf_1b" {
  domain   = "vpc"

  tags = {
    Name = "eip-public-tf-1a"
  }
}

resource "aws_nat_gateway" "natg_1a" {
  allocation_id = aws_eip.eip_tf_1a.id
  subnet_id     = aws_subnet.subnet_public_1a.id

  tags = {
    Name = "ntg-tf-1a"
  }
  depends_on = [aws_internet_gateway.tf_igw]
}

resource "aws_nat_gateway" "natg_1b" {
  allocation_id = aws_eip.eip_tf_1b.id
  subnet_id     = aws_subnet.subnet_public_1b.id

  tags = {
    Name = "ntg-tf-1b"
  }
  depends_on = [aws_internet_gateway.tf_igw]
}



resource "aws_route_table" "tf_rt_private_1a" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natg_1a.id
  }
  tags = {
    Name = "rt-private-1a-tf"
  }
}

resource "aws_route_table" "tf_rt_private_1b" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natg_1b.id
  }
  tags = {
    Name = "rt-private-1b-tf"
  }
}


resource "aws_route_table_association" "subnet_private_1a_associ" {
  subnet_id      = aws_subnet.subnet_private_1a.id
  route_table_id = aws_route_table.tf_rt_private_1a.id
}

resource "aws_route_table_association" "subnet_private_1b_associ" {
  subnet_id      = aws_subnet.subnet_private_1b.id
  route_table_id = aws_route_table.tf_rt_private_1b.id
}