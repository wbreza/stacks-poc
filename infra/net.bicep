param suffix string
param delegations array = []

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${suffix}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'subnet-${suffix}'
  properties: {
    addressPrefix: '10.0.0.0/23'
    delegations: delegations
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output subnetId string = subnet.id
output subnetName string = subnet.name
