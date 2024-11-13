locals {
  db-prefix = "oe-dev-mssql"
}

resource "aws_db_subnet_group" "oe-dev-subnet-group" {
  name       = "${local.db-prefix}-subnet-group"
  subnet_ids = []

  tags = {
    Name = "${local.db-prefix}-subnet-group"
  }
}

module "db" {
  source                                = "terraform-aws-modules/rds/aws"
  identifier                            = "${local.db-prefix}-db"
  engine                                = "sqlserver-ex"
  engine_version                        = "15.00"
  family                                = "sqlserver-ex-15.0" # DB parameter group
  major_engine_version                  = "15.00"             # DB option group
  instance_class                        = "db.t3.small"
  allocated_storage                     = 20
  max_allocated_storage                 = 100
  storage_encrypted                     = false # Encryption at rest is not available for DB instances running SQL Server Express Edition
  username                              = "admin"
  port                                  = 1433
  multi_az                              = false
  db_subnet_group_name                  = aws_db_subnet_group.oe-dev-subnet-group.id
  vpc_security_group_ids                = [module.security_group.security_group_id]
  maintenance_window                    = "Sun:00:00-Sun:03:00"
  backup_window                         = "03:00-06:00"
  enabled_cloudwatch_logs_exports       = ["error"]
  create_cloudwatch_log_group           = true
  backup_retention_period               = 3
  skip_final_snapshot                   = true
  deletion_protection                   = true
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  options                               = []
  create_db_parameter_group             = false
  license_model                         = "license-included"
  timezone                              = "GMT Standard Time"
  character_set_name                    = "Latin1_General_CI_AS"
  tags                                  = var.tags
}


module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  name        = "${local.db-prefix}-sg"
  description = "Complete SqlServer example security group"
  vpc_id      = module.vpc.vpc_id
  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "SqlServer access from within VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    },
  ]

  # egress
  egress_with_source_security_group_id = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow outbound communication to Directory Services security group"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  tags = var.tags
}