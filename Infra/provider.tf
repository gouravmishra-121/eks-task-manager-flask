terraform {
  backend "s3" {
    bucket         = "myinfrastatebucket"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}
