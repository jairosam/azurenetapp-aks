#!/bin/bash
RESOURCE_GROUP="rg-nfs-aks"
LOCATION="eastus2"
ANF_ACCOUNT_NAME="account_nfs"
POOL_NAME="nfs_aks"
SIZE="4" # size in TiB
SERVICE_LEVEL="Standard" # valid values are Standard, Premium and Ultra
VNET_NAME="vnet-eastus2"
SUBNET_NAME_NETAPP="snet-netapp"
SUBNET_NAME_AKS="snet-aks"
SUBNET_PREFIX_NETAPP="10.10.2.0/24"
SUBNET_PREFIX_AKS="10.10.3.0/24"
ADDRESS_SPACE="10.10.0.0/16"

az group create --location $LOCATION --name $RESOURCE_GROUP

az network vnet create \
    --name $VNET_NAME \
    --address-prefixes $ADDRESS_SPACE \
    --resource-group $RESOURCE_GROUP

az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME_NETAPP \
    --delegations "Microsoft.Netapp/volumes" \
    --address-prefixes $SUBNET_PREFIX_NETAPP

az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME_AKS \
    --address-prefixes $SUBNET_PREFIX_AKS

az netappfiles account create \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --account-name $ANF_ACCOUNT_NAME

az netappfiles pool create \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --account-name $ANF_ACCOUNT_NAME \
    --pool-name $POOL_NAME \
    --size $SIZE \
    --service-level $SERVICE_LEVEL

## Get the subnet and VNET ID from the portal
SNET_ID="/subscriptions/${subid}/resourceGroups/rg-nfs-aks/providers/Microsoft.Network/virtualNetworks/vnet-eastus2/subnets/snet-netapp"
VNET_ID="/subscriptions/${subid}/resourceGroups/rg-nfs-aks/providers/Microsoft.Network/virtualNetworks/vnet-eastus2"
UNIQUE_FILE_PATH="files"
VOLUME_SIZE_GIB="100"
VOLUME_NAME="aks-volume"

az netappfiles volume create \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --account-name $ANF_ACCOUNT_NAME \
    --pool-name $POOL_NAME \
    --name $VOLUME_NAME \
    --service-level $SERVICE_LEVEL \
    --vnet $VNET_ID \
    --subnet $SNET_ID \
    --usage-threshold $VOLUME_SIZE_GIB \
    --file-path $UNIQUE_FILE_PATH \
    --protocol-types NFSv3