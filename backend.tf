# backend.tf 

terraform {
  backend "s3" {
    bucket         = "babydoctor-hp-capstone-20250704-xyz123"
    key            = "miniclouddevops/prodution/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking" # Add this line, must match the name above
    encrypt        = true                      # Highly recommended for state file encryption
  }
}


# terraform {
#   backend "s3" {
#     bucket = "digitalwitchngbucketcloud1"
#     key    = "digitalwitchng/prodution/terraform.tfstate"
#     region = "us-west-1"
#   }
# }