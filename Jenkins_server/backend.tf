terraform {
  backend "s3" {
    bucket = "terraformprojectbucket"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
