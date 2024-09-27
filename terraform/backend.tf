# main.tf
terraform {
  backend "remote" {
    organization = "ABaseballCardGuru"
    workspaces {
      name = "aws-whoisoncall"
    }
  }
}
