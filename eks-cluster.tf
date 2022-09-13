##Once the cluster is created, k8s provider will be able to access the cluster to create resources.
provider "kubernetes" {
    ##False so k8s doesn't automatically downloads/installs a default config file in /.kube/config
    ##load_config_file = "false"
    ##Configure provider with the cluster endpoint. K8s cluster endpoint (api server)
    host = data.aws_eks_cluster.bt-eks-cluster.endpoint
    ##Eks token
    token = data.aws_eks_cluster_auth.bt-eks-cluster.token
    ##c_a its a nested attribute, and its needed in a decoded format.
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.bt-eks-cluster.certificate_authority.0.data)
}

##Data sources
##Retrieves eks cluster id, which in fact returns all the whole object.
data "aws_eks_cluster" "bt-eks-cluster" {
    name = module.eks.cluster_id ##maps name variable to the eks-module cluster_id variable.
}
##Retrieves eks cluster auth object
data "aws_eks_cluster_auth" "bt-eks-cluster" {
    name = module.eks.cluster_id
}

##Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name = "bt-eks-cluster"
  cluster_version = "1.23"

  ##subnets where the workload will be scheduled
  subnet_ids = module.bt_eks-vpc.private_subnets
  vpc_id = module.bt_eks-vpc.vpc_id

  ##No required tags like the vpc one. Optional.
  tags = {
    environment = "development"
    application = "microservice"
  }

  ##Takes an array of worker nodes configuration objects. You can define multiple types of worker nodes
  eks_managed_node_groups = {
    dev = {
        min_size = "1"
        max_size = "3"
        desired_size = "3"

        instance_types = ["t2.small"]
        
    }
  }
}