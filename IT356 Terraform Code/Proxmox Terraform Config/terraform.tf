terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.117.0"
    }
  }
}

provider "proxmox" {
    insecure = true
    endpoint = "https://192.168.136.134:8006"
    username = "root@pam"
    password = "P@ssw0rd"
    random_vm_ids = true
    }