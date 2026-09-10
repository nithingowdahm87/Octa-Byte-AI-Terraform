terraform {
  backend "s3" {
    bucket         = "three-tier-app-terraform-state-ap-south-1"
    key            = "staging/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "three-tier-app-terraform-locks"
    encrypt        = true
  }
}
