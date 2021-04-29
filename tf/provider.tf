# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}

provider "snowflake" {
  region  = "ap-southeast-2"
  role = "ACCOUNTADMIN"
}

