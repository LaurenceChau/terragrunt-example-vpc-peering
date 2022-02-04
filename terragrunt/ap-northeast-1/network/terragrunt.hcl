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
  name_prefix = "tko-test-1"
  region      = local.region.locals.aws_region
  cidr_block  = "10.2.0.0/16"
  public_subnets = [
    {
      zone = "a", order = 1, cidr_block = "10.2.1.0/24"
    },
    {
      zone = "c", order = 1, cidr_block = "10.2.2.0/24"
    },
    {
      zone = "d", order = 1, cidr_block = "10.2.3.0/24"
    }
  ]
  private_subnets = [
    {
      zone = "a", order = 1, cidr_block = "10.2.4.0/24"
    },
    {
      zone = "c", order = 1, cidr_block = "10.2.5.0/24"
    },
    {
      zone = "d", order = 1, cidr_block = "10.2.6.0/24"
    }
  ]
}
