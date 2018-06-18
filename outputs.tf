# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.this.id}"
}

# Subnet
output "public_subnet_ids" {
  description = "List of IDs of the public subnet"
  value       = ["${aws_subnet.public.*.id}"]
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnet"
  value       = ["${aws_subnet.private.*.id}"]
}

output "intra_subnet_ids" {
  description = "List of IDs of the intra subnet"
  value       = ["${aws_subnet.intra.*.id}"]
}

output "db_subnet_group" {
  description = "The db subnet group name"
  value       = "${element(concat(aws_db_subnet_group.this.*.id, list("")), 0)}"
}

output "redshift_subnet_group" {
  description = "The Redshift Subnet group ID"
  value       = "${element(concat(aws_redshift_subnet_group.this.*.id, list("")), 0)}"
}

output "elasticache_subnet_group" {
  description = "The ElastiCache Subnet group ID"
  value       = "${element(concat(aws_elasticache_subnet_group.this.*.name, list("")), 0)}"
}

# Route table
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = ["${aws_route_table.public.*.id}"]
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = ["${aws_route_table.private.*.id}"]
}

output "intra_route_table_ids" {
  description = "List of IDs of intra route tables"
  value       = ["${aws_route_table.intra.*.id}"]
}
