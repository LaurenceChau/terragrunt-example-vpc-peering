locals {
  region_vars    = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  aws_region     = local.region_vars.locals.aws_region
}

terraform {
  source = "git::https://github.com/LaurenceChau/my-terraform-modules.git//vpc_peering"
}

include {
  path = find_in_parent_folders()
}

dependency "sg_vpc_1" {
  config_path                             = "../../network"
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_name           = "mock-vpc-name"
    vpc_id             = "mock-vpc-id"
    vpc_cidr_block     = "mock-vpc-cidr-block"
    public_subnet_ids  = ["mock-id1", "mock-id2"]
    private_subnet_ids = ["mock-id1", "mock-id2"]
    subnet_cidr_blocks = {
      mock-subnet-1 = "mock-subnet-cidr-block"
    }
  }
}

dependency "tko_vpc_1" {
  config_path                             = "${get_parent_terragrunt_dir()}/ap-northeast-1/network"
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id             = "mock-vpc-id"
    vpc_cidr_block     = "mock-vpc-cidr-block"
    private_subnet_ids = ["mock-id1", "mock-id2"]
  }
}

inputs = {
  peering_name                       = "sg-vpc-1-tko-vpc-1"
  auto_accept                        = false
  vpc_id                             = dependency.sg_vpc_1.outputs.vpc_id
  # subnet_ids_for_route_tables_filter = dependency.sg_vpc_1.outputs.private_subnet_ids

  peer_region         = "ap-northeast-1"
  peer_vpc_id         = dependency.tko_vpc_1.outputs.vpc_id
  peer_vpc_cidr_block = dependency.tko_vpc_1.outputs.vpc_cidr_block
}
