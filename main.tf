terraform {
  required_providers {
    fly = {
      source  = "fly-apps/fly"
      version = "0.0.21"
    }
  }
}

provider "fly" {
  useinternaltunnel    = true
  internaltunnelorg    = "personal"
  internaltunnelregion = "ams"
}

resource "fly_app" "exampleApp" {
  name = "kandyba-flyiac"
  org  = "personal"
}

resource "fly_ip" "exampleIp" {
  app        = "kandyba-flyiac"
  type       = "v4"
  depends_on = [fly_app.exampleApp]
}

resource "fly_ip" "exampleIpv6" {
  app        = "kandyba-flyiac"
  type       = "v6"
  depends_on = [fly_app.exampleApp]
}

resource "fly_machine" "exampleMachine" {
  for_each = toset(["ams", "arn"])
  app      = "kandyba-flyiac"
  region   = each.value
  name     = "flyiac-${each.value}"
  image    = "flyio/iac-tutorial:latest"
  services = [
    {
      ports = [
        {
          port     = 443
          handlers = ["tls", "http"]
        },
        {
          port     = 80
          handlers = ["http"]
        }
      ]
      "protocol" : "tcp",
      "internal_port" : 80
    },
  ]
  cpus       = 1
  memorymb   = 256
  depends_on = [fly_app.exampleApp]
}
