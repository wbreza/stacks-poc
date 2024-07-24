targetScope = 'subscription'

param envName string = 'stacks-poc'
param location string = 'eastus2'

var suffix = uniqueString(envName, subscription().subscriptionId, location)
var tags = {
  envName: envName
}

resource envGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${envName}-env-${suffix}'
  location: location
  tags: tags
}

resource appGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${envName}-app-${suffix}'
  location: location
  tags: tags
}

resource netGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${envName}-net-${suffix}'
  location: location
  tags: tags
}

module net 'net.bicep' = {
  name: 'net'
  scope: netGroup
  params: {
    suffix: suffix
    delegations: [
      {
        name: 'Microsoft.App.environments'
        id: '/subscriptions/${subscription().subscriptionId}/resourceGroup/${envGroup.name}/providers/Microsoft.Network/availableDelegations/Microsoft.App/environments'
        type: 'Microsoft.Network/availableDelegations'
        properties: {
          serviceName: 'Microsoft.App/environments'
          actions: [
            'Microsoft.Network/virtualNetworks/subnets/join/action'
          ]
        }
      }
    ]
  }
}

module env './env.bicep' = {
  name: 'env'
  scope: envGroup
  params: {
    suffix: suffix
    netGroupName: netGroup.name
    subnetName: net.outputs.subnetName
    virtualNetworkName: net.outputs.vnetName
  }
}

module app './app.bicep' = {
  name: 'app'
  scope: appGroup
  params: {
    suffix: suffix
    envGroupName: envGroup.name
    containerAppsEnvName: env.outputs.environmentName
  }
}
