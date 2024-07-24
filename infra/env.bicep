param envName string
param netGroupName string
param virtualNetworkName string
param subnetName string

resource env 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'cae-${envName}'
  location: resourceGroup().location
  properties: {
    zoneRedundant: false
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    vnetConfiguration: {
      infrastructureSubnetId: subnet.id
      internal: false
    }
  }
}
resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(netGroupName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = {
  parent: vnet
  name: subnetName
}

output environmentId string = env.id
output environmentName string = env.name
