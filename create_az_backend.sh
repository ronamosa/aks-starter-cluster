#!/usr/bin/env bash

set -x

ENV="prod"
RESOURCE_GROUP_NAME="terraform-state-${ENV}"
LOCATION="australiasoutheast"
STORAGE_ACCOUNT_NAME="tfbackend1839"
CONTAINER_NAME="terraform"

echo "create resource group for terraform storage account"
az group create --name ${RESOURCE_GROUP_NAME} --location ${LOCATION}

if [ "$(az storage account check-name --name ${STORAGE_ACCOUNT_NAME} --query nameAvailable)" == "true" ]; then 
echo "no storage account exists. creating '${STORAGE_ACCOUNT_NAME}'..."
  az group create --name ${RESOURCE_GROUP_NAME} --location ${LOCATION}
  az storage account create --resource-group ${RESOURCE_GROUP_NAME} --name ${STORAGE_ACCOUNT_NAME} --sku Standard_LRS --encryption-services blob
  export ARM_ACCESS_KEY=$(az storage account keys list --resource-group ${RESOURCE_GROUP_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --query [0].value -o tsv)
  az storage container create --name ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --account-key ${ARM_ACCESS_KEY}
  echo "storage account for backend successfully created."
else
  echo "storage account ${STORAGE_ACCOUNT_NAME} exists!"
  echo "export ARM_ACCESS_KEY..."
  export ARM_ACCESS_KEY=$(az storage account keys list --resource-group ${RESOURCE_GROUP_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --query [0].value -o tsv)
fi
