##Provider connection
provider "aws" {
    region = "us-east-1"
    profile = "Sandbox"
}

##Variables
variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}

##Resources

##VPC
resource "aws_vpc" "bt_app-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
}

##VPC's subnet
resource "aws_subnet" "bt_app-subnet_1" {
    vpc_id = aws_vpc.bt_app-vpc.id ##We use the vpc_id from the one we created above.
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet_1"
    }
}

##VPC's route table
resource "aws_route_table" "bt_app-routetable_1" {
    vpc_id = aws_vpc.bt_app-vpc.id
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
    vpc_id = aws_vpc.bt_app-vpc.id
    tags = {
      Name: "${var.env_prefix}-ig_1"
    }
}

## Route table & subnet association
resource "aws_route_table_association" "bt_app-association_rt_1" {
    subnet_id = aws_subnet.bt_app-subnet_1.id
    route_table_id = aws_route_table.bt_app-routetable_1.id
}

## Security Group 
resource "aws_security_group" "bt_app-sg_1" {
    name = "bt_app-sg_1"
    vpc_id = aws_vpc.bt_app-vpc.id

    ##Incoming traffic rules
    ##ssh into ec2
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ##access from browser
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ##Exiting/outgoing traffic rules
    ##installations, fetch dependencies
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" ##-1 to not restrict any protocol
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = [] ##for allowing access to vpc endpoints
    }

    tags = {
        Name: "${var.env_prefix}-sg_1"
    }
}

## Data source (in this case works to retrieve a dynamic variable)
data "aws_ami" "latest_amazon_linux_image" {
    most_recent = true ##retrieves most recent image
    owners = ["amazon"]
    ##lets you define the criteria for this query. Example: Amazon gimme the most recent image that have the name that starts with...
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-*-x86_64-gp2"]
    }
}
## EC2
resource "aws_instance" "bt_app-webserver_1" {
    ##Mandatory
    ami = data.aws_ami.latest_amazon_linux_image.id
    instance_type = var.instance_type
    ##Optional (if not specified, aws will grant default options)
    subnet_id = aws_subnet.bt_app-subnet_1.id
    vpc_security_group_ids = [aws_security_group.bt_app-sg_1.id]
    availability_zone = var.avail_zone
    ##Public IP for the ec2
    associate_public_ip_address = true
    ##bootstrap
    user_data = file("entry-script.sh")
    ##Key
    key_name = "bt_app-webserver_1"
    ##Tags
    tags = {
        Name: "${var.env_prefix}-webserver_1"
    }
    ##
    metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
    }
}

