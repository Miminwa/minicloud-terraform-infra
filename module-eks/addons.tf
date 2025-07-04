terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

# Fetch EKS cluster data and token
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

# Kubernetes provider for Terraform-native k8s resources (if used)
provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  alias = "eks"
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}


# NGINX Ingress controller via Helm
resource "helm_release" "nginx_ingress" {
  provider          = helm.eks
  name              = "nginx-ingress"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"
  version           = "4.12.0"
  namespace         = "ingress-nginx"
  create_namespace  = true
  values            = [file("${path.module}/nginx-ingress-values.yaml")]

  depends_on = [aws_eks_node_group.eks_node_group]
}

# Load balancer for ingress controller (waits for Helm)
data "aws_lb" "nginx_ingress" {
  tags = {
    "kubernetes.io/service-name" = "ingress-nginx/nginx-ingress-ingress-nginx-controller"
  }

  depends_on = [helm_release.nginx_ingress]
}

# Cert-manager Helm release
resource "helm_release" "cert_manager" {
  provider          = helm.eks
  name              = "cert-manager"
  repository        = "https://charts.jetstack.io"
  chart             = "cert-manager"
  version           = "1.14.5"
  namespace         = "cert-manager"
  create_namespace  = true

  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]

  depends_on = [helm_release.nginx_ingress]
}

# ArgoCD Helm release
resource "helm_release" "argocd" {
  provider          = helm.eks
  name              = "argocd"
  repository        = "https://argoproj.github.io/argo-helm"
  chart             = "argo-cd"
  version           = "5.51.6"
  namespace         = "argocd"
  create_namespace  = true
  values            = [file("${path.module}/argocd-values.yaml")]

  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager]
}