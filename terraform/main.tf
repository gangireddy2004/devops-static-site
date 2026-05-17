resource "docker_image" "static_site" {
  name = "gangireddy16/devops-static-site:latest"
}

resource "docker_container" "web" {
  name  = "terraform-static-site"
  image = docker_image.static_site.image_id

  ports {
    internal = 80
    external = 8086
  }
}