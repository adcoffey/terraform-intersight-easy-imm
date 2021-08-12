#_________________________________________________________________________
#
# Intersight SSH Policies Variables
# GUI Location: Configure > Policies > Create Policy > SSH > Start
#_________________________________________________________________________

variable "policy_ssh" {
  default = {
    default = {
      description  = ""
      enabled      = true
      organization = "default"
      ssh_port     = 22
      tags         = []
      timeout      = 1800
    }
  }
  description = <<-EOT
  key - Name of the SSH Policy.
  1. description - Description to Assign to the Policy.
  2. enabled - State of SSH service on the endpoint.
  3. organization - Name of the Intersight Organization to assign this Policy to.
    - https://intersight.com/an/settings/organizations/
  4. ssh_port - Port used for secure shell access.  Valid range is between 1-65535.
  5. tags - List of Key/Value Pairs to Assign as Attributes to the Policy.
  6. timeout - Number of seconds to wait before the system considers a SSH request to have timed out.  Valid range is between 60-10800.
  EOT
  type = map(object(
    {
      description  = optional(string)
      enabled      = optional(bool)
      organization = optional(string)
      ssh_port     = optional(number)
      tags         = optional(list(map(string)))
      timeout      = optional(number)
    }
  ))
}


#_________________________________________________________________________
#
# SSH Policies
# GUI Location: Configure > Policies > Create Policy > SSH > Start
#_________________________________________________________________________

module "policy_ssh" {
  depends_on = [
    local.org_moids,
    module.ucs_server_profile
  ]
  source      = "terraform-cisco-modules/imm/intersight//modules/policies_ssh"
  for_each    = local.policy_ssh
  description = each.value.description != "" ? each.value.description : "${each.key} SNMP Policy."
  enabled     = each.value.enabled
  name        = each.key
  org_moid    = local.org_moids[each.value.organization].moid
  ssh_port    = each.value.ssh_port
  profiles = [for s in sort(keys(
  local.ucs_server_profiles)) : module.ucs_server_profile[s].moid if local.ucs_server_profiles[s].policy_ssh == each.key]
  tags    = each.value.tags != [] ? each.value.tags : local.tags
  timeout = each.value.timeout
}
