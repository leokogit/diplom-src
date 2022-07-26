#backend "s3"
terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "netology-bucket-s3"
    region     = "ru-central1-a"
    key        = "states/terraform.tfstate"
    access_key = ""
    secret_key = ""

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
#Create Public IP
/*resource "yandex_vpc_address" "ext_addr" {
  name = "ext_addr"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}*/

#Vm yourdomain / 2vCPU, 2 RAM, External address (Public) и Internal address.
resource "yandex_compute_instance" "vm1" {
  name     = "${terraform.workspace}-ldevops-ru"
  hostname = "yourdomain"
  zone     = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu
      name        = "ubuntu20-ldevops"
      type        = "network-nvme"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sn1.id
    nat       = true
    nat_ip_address     = var.nat_ip_address
#    nat_ip_address     = yandex_vpc_address.ext_addr.external_ipv4_address[0].address
    ip_address = "192.168.1.100"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
#Vms "db01.yourdomain", "db02.ldevops.ru", "app.ldevops.ru", "gitlab.ldevops.ru", "runner.ldevops.ru", "monitoring.ldevops.ru/ external address.
resource "yandex_compute_instance" "vms" {
  count    = local.instance_count[terraform.workspace]
  name     = "${terraform.workspace}-${var.names[count.index]}"
  hostname = var.vm[count.index]
  zone     = "ru-central1-a"

  resources {
    cores  = local.instance_cores[terraform.workspace]
    memory = local.instance_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu
      name        = var.names[count.index]
      type        = "network-hdd"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sn1.id
    ip_address         = var.ip_address[count.index]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
#VPC create
resource "yandex_vpc_network" "network-1" {
  folder_id   = var.yc_folder_id
  name = "network1"
  description = "network1"
}

resource "yandex_vpc_subnet" "sn1" {
  folder_id      = var.yc_folder_id
  name           = "sn1"
  description    = "subnet sn1 "
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  route_table_id = yandex_vpc_route_table.ldevops-rt-a.id
  v4_cidr_blocks = ["192.168.1.0/24"]

  depends_on = [
    yandex_vpc_network.network-1
  ]
}
resource "yandex_vpc_subnet" "sn2" {
  folder_id      = var.yc_folder_id
  name           = "sn2"
  description    = "subnet sn2 "
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.2.0/24"]

  depends_on = [
    yandex_vpc_network.network-1
  ]
}
resource "yandex_vpc_subnet" "sn3" {
  folder_id      = var.yc_folder_id
  name           = "sn3"
  description    = "subnet sn3 "
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.3.0/24"]

  depends_on = [
    yandex_vpc_network.network-1
  ]
}
#Route table for internet for vms over nat instance (proxynginx)
resource "yandex_vpc_route_table" "ldevops-rt-a" {
  network_id = "${yandex_vpc_network.network-1.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.1.100"
  }
}
#locals vars
locals {
  instance_cores = {
    stage = 4
    prod  = 4
  }

  instance_count = {
    stage = 6
    prod  = 6
  }

  instance_memory = {
    stage = 4
    prod  = 4
  }
  ws = {
   stage = 2
   prod  = 4
  }
}

