terraform {
  source = "git::https://github.com/LaurenceChau/my-terraform-modules.git//network"
}

locals {
  region = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name_prefix = "sg-vpc-2"
  region      = local.region.locals.aws_region
  cidr_block  = "10.3.0.0/16"
  public_subnets = [
    {
      zone = "a", order = 1, cidr_block = "10.3.1.0/24"
    },
    {
      zone = "b", order = 1, cidr_block = "10.3.2.0/24"
    },
    {
      zone = "c", order = 1, cidr_block = "10.3.3.0/24"
    }
  ]
  private_subnets = [
    {
      zone = "a", order = 1, cidr_block = "10.3.4.0/24"
    },
    {
      zone = "b", order = 1, cidr_block = "10.3.5.0/24"
    },
    {
      zone = "c", order = 1, cidr_block = "10.3.6.0/24"
    }
  ]
}
