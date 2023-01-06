# Create a VPC.
resource "aws_vpc" "default" {
  cidr_block = "192.168.0.0/16"
}

# Create an internet gateway.
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Add a route table to pass traffic from "public" subnets to the internet gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

# Add a route to the internet gateway for the public subnets.
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Find availability_zones in this region.
data "aws_availability_zones" "default" {
  state = "available"
  # The availability zone "us-east-1e" does not have all instance_types available.
  exclude_names = ["us-east-1e"]
}

# Create (public) subnets.
resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.default.names)
  availability_zone = data.aws_availability_zones.default.names[count.index]
  cidr_block        = "192.168.12${count.index}.0/24"
  vpc_id            = aws_vpc.default.id
}

# Associate the public subnet to the public routing table.
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}
