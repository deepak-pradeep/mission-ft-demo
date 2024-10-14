
# # ############################################################
# # #                 Private Route Table routes 
# # ############################################################

resource "aws_route_table_association" "private_route_table_subnet_association" {
  for_each       = { for v in local.private-subnets : "${v.key}-${v.cidr_block}" => v }
  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_route_table[each.value.key].id
}

resource "aws_route" "tgw_pvt_snet_routes" {
  for_each = {
    for key, value in var.private-subnets :
    key => value
    if value.add_tgw_route == true
  }
  route_table_id         = aws_route_table.private_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

# # ############################################################
# # #                 Public Route Table routes 
# # ############################################################

resource "aws_route_table_association" "public_route_table_subnet_association" {
  for_each       = { for v in local.public-subnets : "${v.key}-${v.cidr_block}" => v }
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_route_table[each.value.key].id
}

resource "aws_route" "igw_routes" {
  for_each = var.public-subnets
  route_table_id              = aws_route_table.public_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway[each.key].id
}


resource "aws_route" "tgw_pub_snet_routes" {
  for_each = {
    for key, value in var.public-subnets :
    key => value
    if value.add_tgw_route == true
  }
  route_table_id         = aws_route_table.public_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}