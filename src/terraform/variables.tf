#token
variable "yc_token" {

   default = ""
}

# ID облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yc_cloud_id" {
  default = "b1g33m4odcr440ndgbq4"
}

# Folder облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yc_folder_id" {
  default = "b1g13q5lhn9pc15991hj"
}

# ID образа
# ID compute image list
variable "ubuntu" {
  default = "fd80d7fnvf399b1c207j"
}

variable "vm" {
  type = list(string)
  default = ["db01.yourdoman", "db02.yourdoman", "app.yourdoman", "gitlab.yourdoman", "runner.yourdoman", "monitoring.yourdoman"]
}
variable "names" {
  type = list(string)
  default = ["db01-yourdoman", "db02-yourdoman", "app-yourdoman", "gitlab-yourdoman", "runner-yourdoman", "monitoring-yourdoman"]
}

# IP address should be already reserved in web UI
variable "nat_ip_address" {
  description = "Public IP address for instance to access the internet over NAT"
  type        = string
  default     = "yourip"
}

/*variable "ip_address" {
  description = "The private IP address to assign to the instance. If empty, the address will be automatically assigned from the specified subnet"
  type        = string
  default     = ""
}*/
variable "ip_address" {
  type = list(string)
  default = ["192.168.1.3", "192.168.1.4", "192.168.1.10", "192.168.1.5", "192.168.1.6", "192.168.1.7"]
}