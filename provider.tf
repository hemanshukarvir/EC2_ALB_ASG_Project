terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "6.4.0"
    }
  }
  backend "s3" {
    bucket = "Add Your Bucket Name here"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  shared_credentials_files = ["Add your Credentials File here"]
  profile = "Add your Profile Name here"
}
