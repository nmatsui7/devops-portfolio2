variable "docker_host" {
  description = "Docker daemon socket to connect to"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "portfolio"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "app_port" {
  description = "Host port mapped to the app container"
  type        = number
  default     = 18080
}
