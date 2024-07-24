targetScope = 'subscription'

param envName string = 'wabrez-stacks-poc'
param location string = 'eastus2'

resource envGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${envName}-env'
  location: location
}

resource appGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${envName}-app'
  location: location
}

resource netGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${envName}-net'
  location: location
}

module net 'net.bicep' = {
  name: 'net'
  scope: netGroup
  params: {
    envName: envName
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
    envName: envName
    netGroupName: netGroup.name
    subnetName: net.outputs.subnetName
    virtualNetworkName: net.outputs.vnetName
  }
}

module app './app.bicep' = {
  name: 'app'
  scope: appGroup
  params: {
    envName: envName
    envGroupName: envGroup.name
    containerAppsEnvName: env.outputs.environmentName
  }
}
