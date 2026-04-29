terraform {
  backend "s3" {
    bucket = "clc15-bmd-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
