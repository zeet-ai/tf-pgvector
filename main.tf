terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.21.0"
    }
  }
}

locals {
  port       = var.port != "" ? var.port : "5432"
  subnet_ids = var.subnet_ids != "" ? split(",", var.subnet_ids) : []
}

module "aws_terraform" {
  source = "github.com/zeet-dev/terraform-aws-rds"

  engine               = "postgres"
  family               = "postgres15"
  major_engine_version = "15"
  create_db_instance   = true
  publicly_accessible  = true

  identifier        = var.identifier
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  db_name           = var.db_name
  username          = var.username
  password          = var.password
  availability_zone = var.availability_zone

  subnet_ids = local.subnet_ids
  port       = local.port
}

data "aws_region" "current" {}

provider "postgresql" {
  host      = module.aws_terraform.db_instance_address
  port      = module.aws_terraform.db_instance_port
  database  = module.aws_terraform.db_instance_name
  username  = module.aws_terraform.db_instance_username
  password  = module.aws_terraform.db_instance_password
  sslmode   = "require"
  superuser = false
}

resource "postgresql_extension" "pgvector" {
  name = "vector"
}

resource "null_resource" "update_visibility" {
  count = var.publicly_accessible ? 0 : 1

  depends_on = [
    postgresql_extension.pgvector
  ]

  triggers = {
    instance_id = module.aws_terraform.db_instance_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws rds modify-db-instance --db-instance-identifier ${module.aws_terraform.db_instance_id} --region ${data.aws_region.current.name} --no-publicly-accessible --apply-immediately
    EOT
  }
}
