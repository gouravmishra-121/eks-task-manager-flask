# resource "aws_vpc" "my_vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = "true"
#   enable_dns_hostnames = "true"
#   tags = {
#     name = "my_vpc"
#   }
# }

# resource "aws_subnet" "public_subnet" {
#   count                   = 2
#   vpc_id                  = aws_vpc.my_vpc.id
#   cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index + 1)
#   availability_zone       = element(data.aws_availability_zones.available.names, count.index)
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "public-subnet-${count.index}"
#   }
# }

# resource "aws_subnet" "private_subnet" {
#   count             = 2
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index + 3) # Adjust the index
#   availability_zone = element(data.aws_availability_zones.available.names, count.index)
#   tags = {
#     Name = "private-subnet-${count.index}"
#   }
# }

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.my_vpc.id
#   tags = {
#     name = "my-igw"
#   }
# }

# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.my_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
#   tags = {
#     name = "public-route-table"
#   }
# }

# resource "aws_route_table_association" "public_rta" {
#   count          = 2
#   subnet_id      = aws_subnet.public_subnet[count.index].id
#   route_table_id = aws_route_table.public_route_table.id
# }

# resource "aws_eip" "nat" {
#   depends_on = [aws_internet_gateway.igw]

#   tags = {
#     name = "nat-eip"
#   }
# }


# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public_subnet[0].id
#   tags = {
#     name = "nat-gateway"
#   }
# }

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }

#   tags = {
#     name = "private-route-table"
#   }
# }

# resource "aws_route_table_association" "private_rta" {
#   count          = 2
#   subnet_id      = aws_subnet.private_subnet[count.index].id
#   route_table_id = aws_route_table.private_route_table.id
# }

# resource "aws_security_group" "eks_node_sg" {
#   vpc_id = aws_vpc.my_vpc.id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 1025
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     name = "eks-node-sg"
#   }
# }


# data "aws_availability_zones" "available" {
#   state = "available"
# }


