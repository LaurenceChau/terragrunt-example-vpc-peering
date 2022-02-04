locals {
  region_vars    = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  aws_region     = local.region_vars.locals.aws_region
}

terraform {
  source = "git::https://github.com/LaurenceChau/my-terraform-modules.git//vpc_peering_accepter"
}

include {
  path = find_in_parent_folders()
}

dependency "tko_vpc_1" {
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

dependency "sg_vpc_1" {
  config_path                             = "${get_parent_terragrunt_dir()}/ap-southeast-1/network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_cidr_block = "mock-vpc-cidr-block"
  }
}

dependency "vpc_peering_request" {
  config_path                             = "${get_parent_terragrunt_dir()}/ap-southeast-1/vpc-peerings/sg-vpc-1-tko-vpc-1/"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    peering_name  = "mock-peeringname"
    connection_id = "mock-conection-id"
  }
}

inputs = {
  vpc_id                             = dependency.tko_vpc_1.outputs.vpc_id
  subnet_ids_for_route_tables_filter = dependency.tko_vpc_1.outputs.private_subnet_ids

  requester_cidr_block = dependency.sg_vpc_1.outputs.vpc_cidr_block

  peering_name  = dependency.vpc_peering_request.outputs.peering_name
  connection_id = dependency.vpc_peering_request.outputs.connection_id
}