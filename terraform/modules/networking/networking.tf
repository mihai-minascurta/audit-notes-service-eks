#Main VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Main-VPC"
  }
}

#Public a subnet
resource "aws_subnet" "public_a" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true #important, gives this subnet an public ip

  tags = {
    Name                                    = "Public-A-Subnet"
    "kubernetes.io/cluster/audit-notes-eks" = "shared" #use audit-notes-eks cluster
    "kubernetes.io/role/elb"                = "1"      #Use internet load balancer
  }
}

#Public b subnet
resource "aws_subnet" "public_b" {
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true #important, gives this subnet an public ip

  tags = {
    Name                                    = "Public-B-Subnet"
    "kubernetes.io/cluster/audit-notes-eks" = "shared" #use audit-notes-eks cluster
    "kubernetes.io/role/elb"                = "1"      #Use internet load balancer
  }
}

#Private a subnet
resource "aws_subnet" "private_a" {
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1a"
  vpc_id            = aws_vpc.main_vpc.id

  tags = {
    Name                                    = "Private-A-Subnet"
    "kubernetes.io/cluster/audit-notes-eks" = "shared" #use audit-notes-eks cluster
    "kubernetes.io/role/internal-elb"       = "1"      #Use internal load balancer
  }
}
#Private b subnet
resource "aws_subnet" "private_b" {
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1b"
  vpc_id            = aws_vpc.main_vpc.id

  tags = {
    Name                                    = "Private-B-Subnet"
    "kubernetes.io/cluster/audit-notes-eks" = "shared" #use audit-notes-eks cluster
    "kubernetes.io/role/internal-elb"       = "1"      #Use internal load balancer
  }
}

#Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Internet-Gateway"
  }

}

#Route table for igw
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

#Public Subnet A asssociation with route table for igw
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_route_table.id
}

#Public Subnet B asssociation with route table for igw
resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_route_table.id
}

#Elastic IP for A ngw
resource "aws_eip" "a_eip" {
  domain = "vpc"
}

#Elastic IP for B ngw
resource "aws_eip" "b_eip" {
  domain = "vpc"
}

#Nat Gateway for A
resource "aws_nat_gateway" "a_ngw" {
  allocation_id = aws_eip.a_eip.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name = "A-NAT-Gateway"
  }
}

#Nat Gateway for B
resource "aws_nat_gateway" "b_ngw" {
  allocation_id = aws_eip.b_eip.id
  subnet_id     = aws_subnet.public_b.id

  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name = "B-NAT-Gateway"
  }
}

#Route table for  Private Subnet A
resource "aws_route_table" "private_a_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.a_ngw.id
  }

  tags = {
    Name = "Private-A-Route-Table"
  }

}

#Route table for  Private Subnet B
resource "aws_route_table" "private_b_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.b_ngw.id
  }

  tags = {
    Name = "Private-B-Route-Table"
  }

}


#Private Subnet A asssociation with route table for A ngw
resource "aws_route_table_association" "private_association_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a_route_table.id
}

#Private Subnet B asssociation with route table for B ngw
resource "aws_route_table_association" "private_association_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b_route_table.id
}

