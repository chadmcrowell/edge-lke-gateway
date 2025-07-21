terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

resource "linode_lke_cluster" "main" {
  label       = "edge-api-cluster"
  region      = "br-gru"
  k8s_version = "1.33"

  pool {
    type  = "g6-standard-2"
    count = 2
  }
}