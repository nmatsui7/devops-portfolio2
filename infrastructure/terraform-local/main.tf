terraform {
  required_version = ">= 1.6"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

resource "docker_network" "app" {
  name = "portfolio-local"
}

resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = false
}

resource "docker_container" "postgres" {
  image   = docker_image.postgres.image_id
  name    = "portfolio-db-local"
  restart = "unless-stopped"

  env = [
    "POSTGRES_DB=portfolio",
    "POSTGRES_USER=${var.db_username}",
    "POSTGRES_PASSWORD=${var.db_password}",
  ]

  networks_advanced {
    name = docker_network.app.name
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.db_username} -d portfolio"]
    interval = "5s"
    timeout  = "3s"
    retries  = 5
  }
}

resource "docker_image" "app" {
  name = "portfolio-app-local"
  build {
    context    = abspath("${path.root}/../../solutions/app")
    dockerfile = "Dockerfile"
    tag        = ["portfolio-app-local:latest"]
  }
}

resource "docker_container" "app" {
  image   = docker_image.app.image_id
  name    = "portfolio-app-local"
  restart = "unless-stopped"

  env = [
    "DATABASE_URL=postgresql://${var.db_username}:${var.db_password}@portfolio-db-local:5432/portfolio",
    "FLASK_ENV=development",
  ]

  ports {
    internal = 80
    external = var.app_port
  }

  networks_advanced {
    name = docker_network.app.name
  }

  depends_on = [docker_container.postgres]
}
