terraform {
  backend "s3" {
    bucket = "terraform-state-reflection"
    key    = "backend/terraform.tfstate"
    region = "eu-central-1"
  }
}
