provider "aws" {
    region = "us-east-1"
    access_key = "AKIAQEQ74B6QQTAKTU4R"
    secret_key = "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"
}

variable vpc_cidr_block {}
variable private_subnets_cidr_blocks {}
variable public_subnets_cidr_blocks {}

data "aws_availability_zones" "azs" {}

module "bt_eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = "bt_eks-vpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnets_cidr_blocks
  public_subnets = var.public_subnets_cidr_blocks
  azs = data.aws_availability_zones.azs.names

  enable_nat_gateway = true
  ##shared nat gateway. All private subnets will route their internet traffic through this single nat gateway.
  single_nat_gateway = true
  ##it assigns private-public dns to ec2's 
  enable_dns_hostnames = true

  ##These tags will help cloud control manager to know to which vpc's, subnets connect to by using the cluster name. This tags are a must. It also helps k8s to distinguish public-private subnets.
  tags = {
    "kubernetes.io/cluster/bt-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/bt-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1 ##provides cloud native lb
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/bt-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}