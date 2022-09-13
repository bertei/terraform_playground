##VPC's subnet
resource "aws_subnet" "bt_app-subnet_1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet_1"
    }
}

##VPC's route table
resource "aws_route_table" "bt_app-routetable_1" {
    vpc_id = var.vpc_id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.bt_app-internetgateway_1.id
    }
    tags = {
      Name: "${var.env_prefix}-routetable_1"
    }
} 

## Internet Gateway
resource "aws_internet_gateway" "bt_app-internetgateway_1" {
    vpc_id = var.vpc_id
    tags = {
      Name: "${var.env_prefix}-ig_1"
    }
}

## Route table & subnet association
resource "aws_route_table_association" "bt_app-association_rt_1" {
    subnet_id = aws_subnet.bt_app-subnet_1.id
    route_table_id = aws_route_table.bt_app-routetable_1.id
}