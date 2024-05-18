provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "ezlearn-terraform-statefile"
    key = "ezlearn-infra"
    region = "us-east-1"
  }
}
resource "aws_instance" "test" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  key_name      = "k8s-key"

  tags = {
    Name = "ezlearn-server"
  }
}

resource "aws_security_group" "test" {
  name = "ezlearn-sg"
  description = "ezlearn infrastructure security"
  vpc_id = "vpc-0f8a37d30d1e3ef5c"
}