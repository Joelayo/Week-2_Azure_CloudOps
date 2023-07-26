#!/bin/bash

# Variables
resourceGroupName="three-tier-cli-rg"
location="East US"
vnetName="three_tier_vnet"
subnetJumpboxName="jumpbox-Subnet"
subnetFrontendName="web-tier-Subnet"
subnetBackendName="app-tier-Subnet"
subnetDatabaseName="db-tier-Subnet"
subnetAppGWName="appgw-Subnet"
jumpboxVMName="jumpbox-vm"

# Prompt for user input
# read -p "Enter the resource group name: " resourceGroupName
# read -p "Enter the location (e.g., East US): " location
# read -p "Enter the virtual network name: " vnetName
# read -p "Enter the jumpbox subnet name: " subnetJumpboxName
# read -p "Enter the frontend subnet name: " subnetFrontendName
# read -p "Enter the backend subnet name: " subnetBackendName
# read -p "Enter the database subnet name: " subnetDatabaseName
# read -p "Enter the jumpbox virtual machine name: " jumpboxVMName

# Automatically retrieve your public IP address
yourPublicIP=$(curl -s https://api.ipify.org)

# Login to Azure (if not already logged in)
az account show 1> /dev/null || az login

# Create a new resource group
az group create --name "$resourceGroupName" --location "$location"

# Create a virtual network with four subnets (Jumpbox, Web-tier, App-tier, and Database)
az network vnet create \
    --resource-group "$resourceGroupName" \
    --name "$vnetName" \
    --location "$location" \
    --address-prefixes 172.20.0.0/16 \
    --subnet-name "$subnetJumpboxName" \
    --subnet-prefix 172.20.1.0/24

az network vnet subnet create \
    --resource-group "$resourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subnetFrontendName" \
    --address-prefix 172.20.2.0/24

az network vnet subnet create \
    --resource-group "$resourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subnetBackendName" \
    --address-prefix 172.20.3.0/24

az network vnet subnet create \
    --resource-group "$resourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subnetDatabaseName" \
    --address-prefix 172.20.4.0/24

az network vnet subnet create \
    --resource-group "$resourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subnetAppGWName" \
    --address-prefix 172.20.0.0/24

# Create a network security group for each subnet
az network nsg create \
    --resource-group "$resourceGroupName" \
    --name "${subnetJumpboxName}-NSG" \
    --location "$location"

az network nsg create \
    --resource-group "$resourceGroupName" \
    --name "${subnetFrontendName}-NSG" \
    --location "$location"

az network nsg create \
    --resource-group "$resourceGroupName" \
    --name "${subnetBackendName}-NSG" \
    --location "$location"

az network nsg create \
    --resource-group "$resourceGroupName" \
    --name "${subnetDatabaseName}-NSG" \
    --location "$location"

# Create default rules for each NSG (Allow SSH from your public IP, Allow HTTP, Allow MySQL)
az network nsg rule create \
    --resource-group "$resourceGroupName" \
    --nsg-name "${subnetJumpboxName}-NSG" \
    --name "AllowSSHFromYourIP" \
    --priority 1000 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "$yourPublicIP" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 22

az network nsg rule create \
    --resource-group "$resourceGroupName" \
    --nsg-name "${subnetFrontendName}-NSG" \
    --name "AllowHTTP" \
    --priority 1000 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 80

az network nsg rule create \
    --resource-group "$resourceGroupName" \
    --nsg-name "${subnetBackendName}-NSG" \
    --name "AllowHTTP" \
    --priority 1000 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 80

az network nsg rule create \
    --resource-group "$resourceGroupName" \
    --nsg-name "${subnetBackendName}-NSG" \
    --name "AllowMySQL" \
    --priority 1010 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 3306

az network nsg rule create \
    --resource-group "$resourceGroupName" \
    --nsg-name "${subnetDatabaseName}-NSG" \
    --name "AllowMySQL" \
    --priority 1000 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 3306

# Associate NSGs with the subnets
az network vnet subnet update \
    --resource-group "$resourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subnetJumpboxName" \
    --network-security-group "${subnetJumpboxName}-NSG"

az network vnet subnet update \
    --resource-group "$resourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subnetFrontendName" \
    --network-security-group "${subnetFrontendName}-NSG"

az network vnet subnet update \
    --resource-group "$resourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subnetBackendName" \
    --network-security-group "${subnetBackendName}-NSG"

az network vnet subnet update \
    --resource-group "$resourceGroupName" \
    --vnet-name "$vnetName" \
    --name "$subnetDatabaseName" \
    --network-security-group "${subnetDatabaseName}-NSG"

# Create the jumpbox virtual machine with the B2 size (Change image if needed)
az vm create \
    --resource-group "$resourceGroupName" \
    --name "JumpboxVM" \
    --location "$location" \
    --vnet-name "$vnetName" \
    --subnet "$subnetJumpboxName" \
    --image "Ubuntu2204" \
    --admin-username "azureuser" \
    --authentication-type "ssh" \
    --ssh-key-value "~/.ssh/host_key.pub" \
    --size "Standard_B2s" \
    --public-ip-sku "Standard"
