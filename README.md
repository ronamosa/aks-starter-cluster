# aks-starter-cluster

basic starter cluster for azure kubernetes service -- no frills, pay-as-you-go friendly.

## Pre-requisites

* `az-cli` installed
* setup azurerm backend to save terraform state to azure
* export ARM_KEY to your env to make az work when you run terraform

### Files included in `/terraform`

| filename | notes |
| --- | --- |
| aks.tf | azure kubernetes service |
| cluster-prod.tfvars | vars to define for this cluster |
| Makefile | used to do all the terraform building |
| network.tf | azure networking, vnet, subnet |
| provider.tf | azure provider 2.0 |
| spn.tf | create aks service principal |
| ssh_keys.tf | creates linux ssh key - dont use this in PROD |
| variables.tf | variable definitions |

## Create your storage account

Lots of ways to do this, but you can run the included script: `./create_az_backend.sh`

Just set these to whatever you want:

```sh
ENV="prod"
RESOURCE_GROUP_NAME="terraform-state-${ENV}"
LOCATION="australiasoutheast"
STORAGE_ACCOUNT_NAME="tfbackend1839"
CONTAINER_NAME="terraform"
```

### ARM_ACCESS_KEY

in the script, make sure this export happens:

`export ARM_ACCESS_KEY=$(az storage account keys list --resource-group ${RESOURCE_GROUP_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --query [0].value -o tsv)`

otherwise, from the output, execute this yourself with the key: `export ARM_ACCESS_KEY=WHATEVERTHEKEYWASWHENYOURANTHESCRIPT`.

check with `env` in your terminal and check it exists. chuck it in your `~/.bashrc` to persist it.

## Update aks.tf

In the `/terraform` folder, update `aks.tf` with the appropriate values from running the `./create_az_backend.sh` script before you build it:

```ruby
terraform {
  backend "azurerm" {
    resource_group_name  = RESOURCE_GROUP_NAME
    storage_account_name = STORAGE_ACCOUNT_NAME
    container_name       = CONTAINER_NAME
    key                  = KEY # e.g. "prod.terraform.tfstate"
  }
}
```

## Makefile build

`ENV` must be set, so just plan and build by going into In the `/terraform` folder and running

`$ ENV=prod make plan`

`$ ENV=prod make apply`
