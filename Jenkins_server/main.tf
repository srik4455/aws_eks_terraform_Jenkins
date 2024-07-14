###VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr


  azs                     = data.aws_availability_zones.available.names
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true




  tags = {
    Name        = "Jenkin_VPC"
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    Name = "Jenkin_subnets"
  }
}
###Security Group

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Jenkins-sg"
  description = "Security group for Jenkins Server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name = "Jenkin_SG"
  }
}

###EC2
# module "ec2_instance" {
#   source = "terraform-aws-modules/ec2-instance/aws"

#   name = "Jenkins-server"

#   instance_type               = "t2.micro"
#   key_name                    = "aws"
#   monitoring                  = true
#   vpc_security_group_ids      = [module.sg.security_group_id]
#   subnet_id                   = module.vpc.public_subnets[0]
#   associate_public_ip_address = true
#   user_data                   = file("jenkins-install.sh")
#   availability_zone           = data.aws_availability_zones.available.names[0]

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Name        = "Jenkins-Server"
#   }
# }
resource "aws_instance" "my-ec2" {
  ami                         = data.aws_ami.my_ami.id
  instance_type               = "t2.micro"
  key_name                    = "aws"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("jenkins-install.sh")
  tags = {
    Name = "Jenkins-Server"
  }


}
