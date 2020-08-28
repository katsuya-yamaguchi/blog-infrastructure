provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::XXXXXXXXXXXXXXXXXX:role/SystemAdmin"
  }
}

terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket   = "tfstate.mini-schna.com"
    region   = "ap-northeast-1"
    key      = "blog/terraform-elb-basic.tfstate"
    encrypt  = true
    role_arn = "arn:aws:iam::XXXXXXXXXXXXXXXXXX:role/SystemAdmin"
  }
}

module "aws" {
  source = "./modules"
}
