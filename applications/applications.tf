# Application Host // Docker

resource "azurerm_storage_account" "appvm_storageaccount" {
  name                     = "app${var.projectPrefix}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = var.tags
}

# network interface for app vm
resource "azurerm_network_interface" "app01-nic" {
  name                = "${var.projectPrefix}-app01-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.appSubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.app01ip
    primary                       = true
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "app-nsg" {
  network_interface_id      = azurerm_network_interface.app01-nic.id
  network_security_group_id = var.security_group.id
}

data "template_file" "prometheus" {
  template = templatefile("${path.module}/../templates/prometheus.yaml", {

  })
}

data "template_file" "filebeat" {
  template = templatefile("${path.module}/../templates/filebeat.yml", {

  })
}

# app01-VM
resource "azurerm_virtual_machine" "app01-vm" {
  name                = "${var.projectPrefix}-app01-vm"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  network_interface_ids = [azurerm_network_interface.app01-nic.id]
  vm_size               = var.instanceType

  storage_os_disk {
    name              = "${var.projectPrefix}-appOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.appvm_storageaccount.primary_blob_endpoint
  }

  os_profile {
    computer_name  = "app01"
    admin_username = var.adminUserName
    admin_password = var.adminPassword
    custom_data    = <<-EOF
#!/bin/bash
apt-get update -y;
apt-get install -y docker.io;
sysctl -w vm.max_map_count=262144
#permissions
usermod -aG docker $USER
usermod -aG docker ${var.adminUserName}
# enable syslog
echo "module(load=\"imtcp\")" >> /etc/rsyslog.conf
echo "input(type=\"imtcp\" port=\"1514\")" >> /etc/rsyslog.conf
echo "module(load=\"imudp\")" >> /etc/rsyslog.conf
echo "input(type=\"imudp\" port=\"1514\")" >> /etc/rsyslog.conf
systemctl restart rsyslog
# demo app
docker run -d -p 443:443 -p 80:80 --restart unless-stopped -e F5DEMO_APP=website \
 -e F5DEMO_NODENAME='F5 Azure' -e F5DEMO_COLOR=ffd734 -e F5DEMO_NODENAME_SSL='F5 Azure (SSL)' \
 -e F5DEMO_COLOR_SSL=a0bf37 chen23/f5-demo-app:ssl;
# juice shop
docker run -d --restart always -p 3000:3000 --name juiceshop bkimminich/juice-shop
# ELK
docker run -d --restart always -p 5601:5601 -p 9200:9200 -p 9300:9300 -p 9600:9600 -p 5044:5044 -it --name elk sebp/elk
sleep 30
# Prometheus
echo ${base64encode(data.template_file.prometheus.rendered)} | base64 --decode >> /var/tmp/prometheus.yml
docker run -d --restart always -p 9090:9090 --name prometheus \
-v /var/tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
# Filebeat
#  Setup
echo ${base64encode(data.template_file.filebeat.rendered)} | base64 --decode >> /var/tmp/filebeat.yml
docker run --link elk:elk docker.elastic.co/beats/filebeat:7.13.3 setup -E setup.kibana.host=elk:5601 -E output.elasticsearch.hosts=["elk:9200"]
#  Run
docker run -d --restart always --link elk:elk -p 6514:6514/udp --name filebeat --user=root \
--volume="/var/log/syslog:/var/log/syslog:ro" \
--volume="/var/tmp/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro" \
--volume="/var/lib/docker/containers:/var/lib/docker/containers:ro" \
docker.elastic.co/beats/filebeat:7.13.3 \
filebeat -e -strict.perms=false
EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}
