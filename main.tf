##Provider connection
provider "aws" {
    region = "us-east-1"
    profile = "Sandbox"
}

##Resources

##VPC
resource "aws_vpc" "bt_app-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
}

##Subnet Module
module "bt_app-subnet_module" {
    source = "./modules/subnet" ##module full/relative path
    subnet_cidr_blocks = var.subnet_cidr_blocks
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.bt_app-vpc.id ##this once is referenced from above resource in this main.tf
}

##EC2 Module
module "bt_app-ec2_module" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.bt_app-vpc.id
    my_ip = var.my_ip
    image_name = var.image_name
    key = var.key
    instance_type = var.instance_type
    subnet_id = module.bt_app-subnet_module.bt_app-subnet_output.id ##i guess that it automatically assigns the vpc which this subnet is assigned
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
}

