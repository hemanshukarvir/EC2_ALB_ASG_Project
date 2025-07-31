terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "6.4.0"
    }
  }
  backend "s3" {
    bucket = "tf-s3-backend-bucket-hkarvir"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  shared_credentials_files = ["C:\\Users\\hkarvir\\.aws\\credentials"]
  profile = "Administrator"
}