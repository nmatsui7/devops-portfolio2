output "app_url" {
  description = "URL to access the portfolio app"
  value       = "http://localhost:${var.app_port}"
}

output "health_check" {
  description = "Health endpoint URL"
  value       = "http://localhost:${var.app_port}/health"
}

output "db_container" {
  description = "PostgreSQL container name"
  value       = docker_container.postgres.name
}

output "app_container" {
  description = "App container name"
  value       = docker_container.app.name
}

output "network" {
  description = "Docker network name"
  value       = docker_network.app.name
}
