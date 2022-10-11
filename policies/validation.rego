package policyascode

default terraform_plan_passes_validation = false

resources_to_validate := input.planned_values.root_module.resources

terraform_plan_passes_validation {
  count(resource_validation_failures) == 0
}

get_validation_failure_for_resource(resource, reason) = resource_failure {
  resource_failure := {
    "address": resource.address,
    "reason": reason
  }
}

resource_validation_failures[vaildation_failure] {
  resource_groups := {resource | resource := resources_to_validate[_]; resource.type == "azurerm_resource_group"}
  resource_groups_without_tags := {rg | rg := resource_groups[_]; rg.values.tags == null}

  vaildation_failure := get_validation_failure_for_resource(resource_groups_without_tags[_], "Resource group is missing tags")
}

resource_validation_failures[vaildation_failure] {
  required_tags_for_security_groups := { "Cost-Center" }

  network_security_groups := { resource | resource := resources_to_validate[_]; resource.type == "azurerm_network_security_group" }  
  network_security_groups_without_required_tags := { nsg | nsg := network_security_groups[_]; required_tags_for_security_groups[tag]; not nsg.values.tags[tag] }

  vaildation_failure := get_validation_failure_for_resource(network_security_groups_without_required_tags[_], "Network security group is missing required tags")
}



resource_validation_failures[vaildation_failure] {
  network_security_group_name_pattern := "^pepsico-nsg-.{3,}"

  network_security_groups := { resource | resource := resources_to_validate[_]; resource.type == "azurerm_network_security_group" }  
  network_security_groups_without_valid_names := { nsg | nsg := network_security_groups[_]; not regex.match(network_security_group_name_pattern, nsg.values.name) }

  vaildation_failure := get_validation_failure_for_resource(network_security_groups_without_valid_names[_], "Network security group has an invalid name")
}
Footer
© 2022 GitHub, Inc.
Footer navigation
Terms
