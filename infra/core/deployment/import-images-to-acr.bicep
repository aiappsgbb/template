@description('The name of the Azure Container Registry')
param acrName string

@description('Images to import into the ACR')
param imagesToImport array = [
  {
    sourceName: 'mcr.microsoft.com/k8se/quickstart:latest'
    targetName: 'quickstart:latest'
  }
]

@description('The Azure region where the deployment script will run')
param location string = resourceGroup().location

@description('Tags to apply to the deployment script')
param tags object = {}

@description('User assigned managed identity for the deployment script')
param managedIdentityId string

// Import images to ACR using deployment script
resource importImages 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'import-images-to-acr'
  location: location
  tags: tags
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    azCliVersion: '2.50.0'
    retentionInterval: 'PT1H'
    timeout: 'PT30M'
    scriptContent: '''
      #!/bin/bash
      set -e
      
      echo "Starting image import to ACR: $ACR_NAME"
      
      # Parse the images JSON array
      echo $IMAGES_TO_IMPORT | jq -c '.[]' | while read -r image; do
        SOURCE_NAME=$(echo $image | jq -r '.sourceName')
        TARGET_NAME=$(echo $image | jq -r '.targetName')
        
        echo "Importing $SOURCE_NAME as $TARGET_NAME"
        az acr import \
          --name $ACR_NAME \
          --source $SOURCE_NAME \
          --image $TARGET_NAME \
          --force
      done
      
      echo "Image import completed successfully"
    '''
    environmentVariables: [
      {
        name: 'ACR_NAME'
        value: acrName
      }
      {
        name: 'IMAGES_TO_IMPORT'
        value: string(imagesToImport)
      }
    ]
  }
}

output deploymentScriptId string = importImages.id
output deploymentScriptName string = importImages.name
