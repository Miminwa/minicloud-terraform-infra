# # modules/dns/variables.tf (Use this version)

# variable "environment" {
#   description = "The deployment environment (e.g., 'dev', 'prod')."
#   type        = string
# }

# variable "domain_name" { # This is correct: 'domain_name' (with underscore)
#   description = "The root domain name for your Route 53 Hosted Zone (e.g., 'yourdomain.com')."
#   type        = string
# }

# variable "nginx_lb_dns_name" { # This is the consolidated and correct variable for the LB DNS Name
#   description = "The DNS name (hostname) of the NGINX Ingress Load Balancer (NLB/ALB) from your EKS module."
#   type        = string
# }

# variable "nginx_lb_hosted_zone_id" { # CRITICAL: You MUST add this variable for ALIAS records to work
#   description = "The AWS-specific Route 53 Hosted Zone ID of the NGINX Ingress Load Balancer."
#   type        = string
# }


variable "environment" {}
variable "domain_name" {}
variable "nginx_ingress_lb_dns" {
  description = "DNS name of the NGINX Ingress Load Balancer"
  type        = string  
  
}
variable "nginx_lb_ip" {
  description = "IP address of the NGINX Ingress Load Balancer"
  type        = string
}
variable "nginx_ingress_load_balancer_hostname" {
  description = "Hostname of the NGINX Ingress Load Balancer"
  type        = string
}