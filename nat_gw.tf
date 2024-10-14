resource "aws_eip" "nat_gw_eip" {
  for_each = { 
    for key, value in local.public-subnets : 
        "${value.key}-${value.cidr_block}" => value 
        if value.create_nat == true
   }
  domain = "vpc"
  tags = merge(var.default_tags, {
    Name = "euw1-${each.value.vpc_key}-eip"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = { 
    for key, value in local.public-subnets : 
        "${value.key}-${value.cidr_block}" => value
        if value.create_nat == true
   }
  allocation_id = aws_eip.nat_gw_eip[each.key].id
  subnet_id = aws_subnet.public_subnets[each.key].id
  tags = merge(var.default_tags, {
    Name = "euw1-${each.value.vpc_key}-nat-gw"
  })
}

resource "aws_route" "nat_gw_routes" {
  for_each = { 
    for key, value in local.private-subnets : 
        "${value.key}-${value.cidr_block}" => value
        if value.nat_gw_key != null
   }
  route_table_id              = aws_route_table.private_route_table[each.value.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw[each.value.nat_gw_key].id
}
