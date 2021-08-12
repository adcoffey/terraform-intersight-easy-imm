#_________________________________________________________________________
#
# Intersight Network Connectivity Policies Variables
# GUI Location: Configure > Policies > Create Policy > Network Connectivity
#_________________________________________________________________________

variable "policy_network_connectivity" {
  default = {
    default = {
      description    = ""
      dns_servers_v4 = ["208.67.220.220", "208.67.222.222"]
      dns_servers_v6 = []
      dynamic_dns    = false
      ipv6_enable    = false
      organization   = "default"
      tags           = []
      update_domain  = ""
    }
  }
  description = <<-EOT
  key - Name of the Network Connectivity Policy.
  1. description - Description to Assign to the Policy.
  2. dns_servers_v4 - List of IPv4 DNS Servers for this DNS Policy.
  3. dns_servers_v6 - List of IPv6 DNS Servers for this DNS Policy.
  4. dynamic_dns - Flag to Enable or Disable Dynamic DNS on the Policy.  Meaning obtain DNS Servers from DHCP Service.
  5. ipv6_enable - Flag to Enable or Disable IPv6 on the Policy.
  6. organization - Name of the Intersight Organization to assign this Policy to.
    - https://intersight.com/an/settings/organizations/
  7. tags - List of Key/Value Pairs to Assign as Attributes to the Policy.
  8. update_domain - Name of the Domain to Update when using Dynamic DNS for the Policy.
  EOT
  type = map(object(
    {
      description    = optional(string)
      dns_servers_v4 = optional(set(string))
      dns_servers_v6 = optional(set(string))
      dynamic_dns    = optional(bool)
      ipv6_enable    = optional(bool)
      organization   = optional(string)
      tags           = optional(list(map(string)))
      update_domain  = optional(string)
    }
  ))
}


#_________________________________________________________________________
#
# Network Connectivity Policies
# GUI Location: Configure > Policies > Create Policy > Network Connectivity
#_________________________________________________________________________

module "policy_network_connectivity" {
  depends_on = [
    local.org_moids,
    module.ucs_server_profile
  ]
  source         = "terraform-cisco-modules/imm/intersight//modules/policies_network_connectivity"
  for_each       = local.policy_network_connectivity
  description    = each.value.description != "" ? each.value.description : "${each.key} Network Connectivity (DNS) Policy."
  dns_servers_v4 = each.value.dns_servers_v4
  dns_servers_v6 = each.value.dns_servers_v6
  dynamic_dns    = each.value.dynamic_dns
  ipv6_enable    = each.value.ipv6_enable
  name           = each.key
  org_moid       = local.org_moids[each.value.organization].moid
  profiles = [for s in sort(keys(
  local.ucs_server_profiles)) : module.ucs_server_profile[s].moid if local.ucs_server_profiles[s].policy_network_connectivity == each.key]
  tags          = each.value.tags != [] ? each.value.tags : local.tags
  update_domain = each.value.update_domain
}


