terraform {
  required_version = ">= 1.6"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

# Création du réseau pour faire communiquer Web et DB
resource "docker_network" "main" {
  name = "devops-${var.environment}"
}

# Appel du module WebApp
module "webapp" {
  source      = "../../modules/webapp"
  app_name    = var.app_name
  environment = var.environment
  port        = var.web_port
  replicas    = var.web_replicas
  network_id  = docker_network.main.name
}

# Appel du module Database
module "database" {
  source      = "../../modules/database"
  app_name    = var.app_name
  environment = var.environment
  db_password = var.db_password
  db_port     = var.db_port
  network_id  = docker_network.main.name
}

# Définition des variables
variable "app_name" { type = string }
variable "environment" { type = string }
variable "web_port" { type = number }
variable "web_replicas" { type = number }
variable "db_port" { type = number }

variable "db_password" {
  type      = string
  sensitive = true
}

# Affichage des résultats
output "web_urls" {
  value = module.webapp.urls
}