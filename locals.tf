locals {
  private-subnets = flatten([
    for k1, v1 in var.private-subnets : [
      for v2 in v1.subnets : {
        key                        = k1
        cidr_block                 = v2.cidr_block
        custom_private_subnet_tags = v2.custom_private_subnet_tags
        name                       = v2.name
        vpc_key                    = v1.vpc_key
        subnet_purpose             = v1.subnet_purpose
        nat_gw_key                 = v1.nat_gw_key
      }
  ]])

  public-subnets = flatten([
    for k1, v1 in var.public-subnets : [
      for v2 in v1.subnets : {
        key                       = k1
        cidr_block                = v2.cidr_block
        custom_public_subnet_tags = v2.custom_public_subnet_tags
        name                      = v2.name
        vpc_key                   = v1.vpc_key
        create_nat                = v1.create_nat
      }
  ]])
}