terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0b2eed9bc374d87a9"
  instance_type = "t2.micro"
  subnet_id = "subnet-0cf4eaf0747061fdc"
  

  tags = {
    Name = var.instance_name
  }
}