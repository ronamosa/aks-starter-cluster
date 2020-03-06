resource "azuread_application" "spn" {
  name = "aks-spn-${var.env}"
}

resource "random_password" "spn" {
  length  = 20
  special = true
}

resource "azuread_service_principal" "spn" {
  application_id = azuread_application.spn.application_id
}

resource "azuread_service_principal_password" "spn" {
  service_principal_id = azuread_service_principal.spn.id
  value                = random_password.spn.result
  end_date_relative    = "8760h"
}

output "spn_application_id" {
  value = azuread_service_principal.spn.application_id
}

output "spn_password" {
  value = azuread_service_principal_password.spn.value
}