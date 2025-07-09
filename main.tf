# Creating a VPC and EKS cluster using Terraform
module "vpc-deployment" {
    source = "./module-vpc"
    
    environment = var.environment
    vpc_cidrblock = var.vpc_cidrblock
    countsub = var.countsub
    create_subnet = var.create_subnet
    create_elastic_ip = var.create_elastic_ip
  
}

#creating an EKS cluster using Terraform
# and deploying it in the VPC created above
module "eks-deployment" {
    source = "./module-eks"
    
    environment = var.environment
    vpc_cidrblock = var.vpc_cidrblock
    countsub = var.countsub
    create_subnet = var.create_subnet
    create_elastic_ip = var.create_elastic_ip
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
    instance_types = var.instance_types
    capacity_type = var.capacity_type
    public_subnet_ids  = module.vpc-deployment.public_subnet_ids
    private_subnet_ids = module.vpc-deployment.private_subnet_ids
    cluster_name = var.cluster_name
    repository_name = var.repository_name
    domain-name = var.domain-name
    email = var.email
  
}

# module "namecheap-deployment" {
#     source = "./module-dns"
#     environment = var.environment
#     domain_name = var.domain-name
#     nginx_lb_dns_name = module.eks-deployment.nginx_lb_dns_name
#     nginx_lb_hosted_zone_id = module.eks-deployment.nginx_lb_hosted_zone_id
  
# }

module "rds-mysql-deployment" {
    source = "./module-database"
    environment = var.environment
    db_instance_class = var.db_instance_class
    db_allocated_storage = var.db_allocated_storage
    private_subnet_db_ids = module.vpc-deployment.private_subnet_db_ids
    db_name =  var.db_name
    db_password = var.db_password
    db_username = var.db_username
    aws_security_group_ids = module.vpc-deployment.aws_security_group_ids
}

# # to reach the EC2 instance running NGINX.

# resource "aws_security_group_rule" "allow_git_runner_http" {
#   # The ID of the security group attached to your 'github-runner-private' EC2 instance
#   security_group_id = "sg-0a628810f04919079"
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   # The public IP address of your Git runner, followed by /32 for a single host
#   cidr_blocks       = ["3.83.140.116/32"]
#   description       = "Allow HTTP from Git Runner"
# }

# resource "aws_security_group_rule" "allow_git_runner_https" {
#   # The ID of the security group attached to your 'github-runner-private' EC2 instance
#   security_group_id = "sg-0a628810f04919079"
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   # The public IP address of your Git runner, followed by /32 for a single host
#   cidr_blocks       = ["3.83.140.116/32"]
#   description       = "Allow HTTPS from Git Runner"
# }
