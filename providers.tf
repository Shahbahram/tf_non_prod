#Defining multiple providers using "alias" parameter
provider "aws" {
  profile = var.profile
  region  = var.region-primary
  alias   = "region-primary"
}