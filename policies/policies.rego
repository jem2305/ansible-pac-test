package corp.policies

########################
# Parameters for Policy
########################

# Consider only these resource types in policy evaluations
all_resource_types := {"ibm_cloudant"}

#########
# Policy
#########

# Input passes validation if there are no policy violations for input
# with level = 'BLOCK'
default passes_validation := false
passes_validation {
    num_blocks := count( [ v | v := policy_violations[_]; v.level == LEVEL.BLOCK ] )
    num_blocks == 0
}

# -----------------------------------------------------------------------------
# Policy:       CORP-040-00001
# Description:  All ibm_cloudant resources must contain a tag matching
#               costcenter:NNNNNN where N is some number 0-9
# -----------------------------------------------------------------------------
CORP_040_00001_id := "CORP-040-00001"
CORP_040_00001_message := "Resource is missing costcenter tag or does not comply to required regex"

# add CORP_040_00001 policy to policy set
policies[policy_id] := policy {
    policy_id := CORP_040_00001_id
    policy := {
        "reason": CORP_040_00001_message,
        "level": LEVEL.BLOCK
    }
}

# add CORP_040_00001 violations to violations list if any exist
policy_violations[CORP_040_00001_violation] {

    # select all resources that require a costcenter tag
    resources_requiring_costcenter_tag := array.concat(
        resources["ibm_cloudant"],
        []
    )

    # get a list of resources that comply with the costcenter tag policy
    with_costcenter_tag := { index |
        some index, tag

        # check that some tag matches the required regex for each
        regex.match(
            "^costcenter:(\\d){6}$", 
            resources_requiring_costcenter_tag[index].values.tags[tag]
        )
    }

    # get a list of of non-compliant resources [all resouces minus compliant resources]
    without_costcenter_tag := { index |
        some index
        resources_requiring_costcenter_tag[index]
        not with_costcenter_tag[index]
    }

    # loop through without_costcenter_tag[] and create a new policy violation
    CORP_040_00001_violation := new_violation(
        CORP_040_00001_id,
        resources_requiring_costcenter_tag[ without_costcenter_tag[_] ]
    )

}

####################
# Common Library
####################

# Constants for policy levels
LEVEL := {
    "BLOCK": "BLOCK",
    "WARN": "WARN"
}

# list of all resources of a given type
resources[resource_type] := all {
    some resource_type
    all_resource_types[resource_type]

    # query all resources from input and convert to a standard format
    all := array.concat(
        # Terraform resources
        tf_resources[resource_type],

        # Future resource type
        []
    )
}

new_violation(policy_id, resource) = resource_failure {
  resource_failure := {
    "id": resource.id,
    "policy_id": policy_id,
    "reason": policies[policy_id].reason,
    "level": policies[policy_id].level
  }
}

####################
# Terraform Library
####################

tf_resources[resource_type] := all {
    some resource_type
    all_resource_types[resource_type]

    all := [resource | 
        tf_resource := input.tfplan.resource_changes[_]
        resource := standardize_terraform(tf_resource)
        resource.type == resource_type
    ]
}

standardize_terraform(tf_resource) = std_resource {
    std_resource := {
        "id": tf_resource.address,
        "type": tf_resource.type,
        "values": tf_resource.change.after
    }
}