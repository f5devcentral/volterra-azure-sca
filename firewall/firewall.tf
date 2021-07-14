#BIG-IP AFM

resource "azurerm_storage_account" "bigip_storageaccount" {
  name                     = "diag${var.projectPrefix}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = var.tags
}

# Create a Public IP for the Virtual Machines
resource "azurerm_public_ip" "f5vmpip01" {
  name                = "${var.projectPrefix}-vm01-mgmt-pip01-delete-me"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name = "${var.projectPrefix}-f5vm-public-ip-delete-me"
  }
}

#Create the first network interface card for Management
resource "azurerm_network_interface" "vm01-mgmt-nic" {
  name                = "${var.projectPrefix}-vm01-mgmt-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnetMgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5_mgmt["f5vm01mgmt"]
    public_ip_address_id          = azurerm_public_ip.f5vmpip01.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "mgmt-nsg" {
  network_interface_id      = azurerm_network_interface.vm01-mgmt-nic.id
  network_security_group_id = var.security_group.id
}

# Create the second network interface card for External
resource "azurerm_network_interface" "vm01-ext-nic" {
  name                          = "${var.projectPrefix}-vm01-ext-nic"
  location                      = var.resource_group.location
  resource_group_name           = var.resource_group.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.bigip_version == "latest" ? true : false

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnetExternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5_t1_ext["f5vm01ext"]
    primary                       = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = var.subnetExternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5_t1_ext["f5vm01ext_sec"]
  }
  ip_configuration {
    name                          = "tertiary"
    subnet_id                     = var.subnetExternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5_t1_ext["f5vm01ext_thi"]
  }
  ip_configuration {
    name                          = "quarternary"
    subnet_id                     = var.subnetExternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5_t1_ext["f5vm01ext_fou"]
  }

  tags = {
    Name                      = "${var.projectPrefix}-vm01-ext-int"
    environment               = var.tags["environment"]
    owner                     = var.tags["owner"]
    group                     = var.tags["group"]
    costcenter                = var.tags["costcenter"]
    application               = var.tags["application"]
    f5_cloud_failover_label   = "saca"
    f5_cloud_failover_nic_map = "external"
  }
}

resource "azurerm_network_interface_security_group_association" "app-nsg" {
  network_interface_id      = azurerm_network_interface.vm01-ext-nic.id
  network_security_group_id = var.app_security_group.id
}

# Create the third network interface card for Internal
resource "azurerm_network_interface" "vm01-int-nic" {
  name                          = "${var.projectPrefix}-vm01-int-nic"
  location                      = var.resource_group.location
  resource_group_name           = var.resource_group.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.bigip_version == "latest" ? true : false

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnetInternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5_t1_int["f5vm01int"]
    primary                       = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = var.subnetInternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5_t1_int["f5vm01int_sec"]
  }

  tags = var.tags
}

# Obtain Gateway IP for each Subnet
locals {
  depends_on = [var.subnetMgmt.id, var.subnetExternal.id]
  mgmt_gw    = cidrhost(var.subnetMgmt.address_prefix, 1)
  ext_gw     = cidrhost(var.subnetExternal.address_prefix, 1)
  int_gw     = cidrhost(var.subnetInternal.address_prefix, 1)
}

# as3 uuid generation
resource "random_uuid" "as3_uuid" {}

data "http" "onboard" {
  url = "https://raw.githubusercontent.com/Mikej81/f5-bigip-hardening-DO/master/dist/terraform/latest/${var.licenses["license1"] != "" ? "byol" : "payg"}_standalone.json"
}

data "http" "appservice" {
  url = "https://raw.githubusercontent.com/Mikej81/f5-bigip-hardening-AS3/master/dist/terraform/latest/sccaVoltSingleTier.json"
}

data "template_file" "vm01_do_json" {
  template = data.http.onboard.body
  vars = {
    host1      = var.hosts["host1"]
    local_host = var.hosts["host1"]
    #external_selfip = "${var.f5_t1_ext["f5vm01ext"]}/${element(split("/", var.subnets["external"]), 1)}"
    external_selfip = "${var.f5_t1_ext["f5vm01ext"]}/${element(split("/", var.subnets["internal"]), 1)}"
    #internal_selfip = "${var.f5_t1_int["f5vm01int"]}/${element(split("/", var.subnets["internal"]), 1)}"
    internal_selfip = "${var.f5_t1_int["f5vm01int"]}/${element(split("/", var.subnets["inspect_int"]), 1)}"
    log_localip     = var.f5_t1_int["f5vm01int"]
    log_destination = var.app01ip
    appSubnet       = var.subnets["application"]
    vnetSubnet      = var.cidr
    externalGateway = local.ext_gw
    internalGateway = local.int_gw
    mgmtGateway     = local.mgmt_gw
    dns_server      = var.dns_server
    ntp_server      = var.ntp_server
    timezone        = var.timezone
    admin_user      = var.adminUserName
    admin_password  = var.adminPassword
    license         = var.licenses["license1"] != "" ? var.licenses["license1"] : ""
  }
}

data "template_file" "as3_json" {
  template = data.http.appservice.body
  vars = {
    uuid                = random_uuid.as3_uuid.result
    baseline_waf_policy = var.asm_policy
    exampleVipAddress   = var.f5_t1_ext["f5vm01ext_thi"]
    exampleVipSubnet    = var.f5_t1_ext["f5vm01ext_thi"]
    example_vs_address  = var.f5_t1_ext["f5vm01ext_thi"]
    rdp_pool_addresses  = var.app01ip
    ssh_pool_addresses  = var.app01ip
    app_pool_addresses  = var.app01ip
    ips_pool_addresses  = var.app01ip
    log_destination     = var.app01ip
    mgmtVipAddress      = var.f5_t1_ext["f5vm01ext"]
    mgmtVipAddress2     = var.f5_t1_ext["f5vm01ext"]
    transitVipAddress   = var.f5_t1_int["f5vm01int_sec"]
    transitVipAddress2  = var.f5_t1_int["f5vm01int_sec"]
  }
}


data "template_file" "startup_script" {
  template = templatefile("${path.module}/../templates/startup_script.tpl", {
    uname                = var.adminUserName
    upassword            = var.adminPassword
    mgmtGateway          = local.mgmt_gw
    keyvault_uri         = var.azure_key_vault_uri
    secret_id            = var.azure_key_vault_secret
    declative_onboarding = data.template_file.vm01_do_json.rendered
    application_services = data.template_file.as3_json.rendered
  })
}

# Create F5 BIGIP VMs
resource "azurerm_virtual_machine" "f5vm01" {
  name                         = "${var.projectPrefix}-f5vm01"
  location                     = var.resource_group.location
  resource_group_name          = var.resource_group.name
  primary_network_interface_id = azurerm_network_interface.vm01-mgmt-nic.id
  network_interface_ids        = [azurerm_network_interface.vm01-mgmt-nic.id, azurerm_network_interface.vm01-ext-nic.id, azurerm_network_interface.vm01-int-nic.id]
  vm_size                      = var.instanceType
  availability_set_id          = var.availability_set.id

  depends_on = [
    var.azure_key_vault_secret
  ]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = var.product
    sku       = var.image_name
    version   = var.bigip_version
  }

  storage_os_disk {
    name              = "${var.projectPrefix}vm01-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.projectPrefix}vm01"
    admin_username = var.adminUserName
    admin_password = var.adminPassword
    custom_data    = base64encode(data.template_file.startup_script.rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.bigip_storageaccount.primary_blob_endpoint
  }

  plan {
    name      = var.image_name
    publisher = "f5-networks"
    product   = var.product
  }

  tags = var.tags
}

# #Do runtime-init
# resource "azurerm_virtual_machine_extension" "run_startup_cmd" {
#   name                 = "${var.projectPrefix}-run-startup-cmd"
#   virtual_machine_id   = azurerm_virtual_machine.f5vm01.id
#   publisher            = "Microsoft.OSTCExtensions"
#   type                 = "CustomScriptForLinux"
#   type_handler_version = "1.2"
#   settings             = <<SETTINGS
#     {
#       "commandToExecute": "bash /var/lib/waagent/CustomData"
#     }
# SETTINGS
# }

# Debug Template Outputs
resource "local_file" "vm01_do_file" {
  content  = data.template_file.vm01_do_json.rendered
  filename = "${path.module}/../debug/vm01_do_data.json"
}

resource "local_file" "vm_as3_file" {
  content  = data.template_file.as3_json.rendered
  filename = "${path.module}/../debug/vm_as3_data.json"
}

resource "local_file" "onboard_file" {
  content  = data.template_file.startup_script.rendered
  filename = "${path.module}/../debug/startup-init.sh"
}

output "azurerm_public_ip_pip" {
  value = azurerm_public_ip.f5vmpip01.ip_address
}
