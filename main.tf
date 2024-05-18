provider "aws" {
  region = "us-east-1"
}
provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "ezlearn-statefile-bucket"
    key = "ezlearn-infra-state"
    region = "us-east-1"
  }
}

resource "aws_instance" "test" {
  ami = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  key_name = "k8s-key"

  vpc_security_group_ids = [aws_security_group.ezlearn-sg.id]

  tags = {
  Name = "ezlearn-server"
 }
}

resource "aws_security_group" "ezlearn-sg" {
  name = "ezlearn-infra-sg"
  description = "infrastructure security group"
  vpc_id = "vpc-0f8a37d30d1e3ef5c"

  tags = {
    Name = "ezlearn-infra-sg"
  }
}
