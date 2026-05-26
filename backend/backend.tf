terraform {
  backend "s3" {
    bucket         = "sravani-terraform-backend"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}