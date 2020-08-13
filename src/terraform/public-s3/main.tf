provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::XXXXXXXXXX:role/SystemAdmin"
  }
}

terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket   = "tfstate.mini-schna.com"
    region   = "ap-northeast-1"
    key      = "blog/public-s3.tfstate"
    encrypt  = true
    role_arn = "arn:aws:iam::XXXXXXXXXX:role/SystemAdmin"
  }
}

module "aws" {
  source = "./modules"
}
