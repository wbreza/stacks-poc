param envGroupName string
param containerAppsEnvName string
param suffix string

resource app 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'aca-app-${suffix}'
  location: resourceGroup().location
  properties: {
    environmentId: env.id
    configuration: {
      ingress: {
        external: true
        transport: 'auto'
        allowInsecure: false
        targetPort: 80
      }
    }
    workloadProfileName: 'Consumption'
    template: {
      scale: {
        minReplicas: 0
      }
      containers:[
        {
          name: 'nginx'
          image: 'docker.io/nginx'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
    }
  }
}

resource env 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppsEnvName
  scope: resourceGroup(envGroupName)
}
