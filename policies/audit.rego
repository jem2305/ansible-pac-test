package policyascode.audit

get_validation_failure_for_resource(resource, reason, playbook, playbook_variables) = resource_failure {
  resource_failure := {
    "resource": resource,
    "reason": reason,
    "playbook": playbook,
    "playbook_variables": playbook_variables
  }
}

resource_validation_failures[vaildation_failure] {
  nsgs_with_attached_vms := {nsg | nsg := input.securitygroups[_]; count( nsg.network_interfaces ) != 0 }
  vaildation_failure := get_validation_failure_for_resource(nsgs_with_attached_vms[_], "Network security groups must be assigned at the subnet level, not on the individual VM level.", "Not implemented", {})
}

resource_validation_failures[vaildation_failure] {
  nsg_rules_with_protocol_type_any := {nsg_rule | nsg_rule := input.securitygroups[_].rules[_]; nsg_rule.protocol == "*" }
  vaildation_failure := get_validation_failure_for_resource(nsg_rules_with_protocol_type_any[_], "Network security group rule must not use 'Any' type, must select TCP/UDP/ICMP.", "playbooks/change_nsg_rule_protocol_type.yaml", {"id": nsg_rules_with_protocol_type_any[_].id, "new_protocol": "FIXME: Tcp/Udp/Icmp"})
}

resource_validation_failures[vaildation_failure] {
  nsg_rules_with_source_port_range_any := {nsg_rule | nsg_rule := input.securitygroups[_].rules[_]; nsg_rule.source_port_range == "*" }
  vaildation_failure := get_validation_failure_for_resource(nsg_rules_with_source_port_range_any[_], "Network security group rule must not use '*' for source port range.", "Not implemented", {})
}

resource_validation_failures[vaildation_failure] {
  nsg_rules_with_destination_port_range_any := {nsg_rule | nsg_rule := input.securitygroups[_].rules[_]; nsg_rule.source_port_range == "*" }
  vaildation_failure := get_validation_failure_for_resource(nsg_rules_with_destination_port_range_any[_], "Network security group rule must not use '*' for destination port range.", "Not implemented", {})
}