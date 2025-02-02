terraform {
  backend "s3" {
    bucket         = "aws-bucket-w20"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    
  }
}