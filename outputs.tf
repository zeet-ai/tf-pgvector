output "db_instance_host" {
  description = "The database host"
  value       = module.aws_terraform.db_instance_address
}

output "db_instance_port" {
  description = "The database port"
  value       = module.aws_terraform.db_instance_port
}

output "db_instance_name" {
  description = "The database name"
  value       = module.aws_terraform.db_instance_name
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.aws_terraform.db_instance_id
}

output "db_instance_region" {
  description = "The database instance region"
  value       = data.aws_region.current.name
}
