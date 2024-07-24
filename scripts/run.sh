#!/bin/bash

# Variables
deploymentType="stack"
deploymentMode="create"
subscriptionId=""
location="eastus2"
bicepFilePath="../infra/main.bicep"
parametersFilePath="../infra/main.bicepparam"
environmentName=""

# Function to display usage
usage() {
    echo "Usage: $0 -t <deployment-type> -m <deployment-mode> -s <subscription-id> -l <location> -n <environment-name>"
    echo "  -n: Environment name (Required)"
    echo "  -t: Type of deployment (standard or stack)"
    echo "  -m: Mode of deployment (create or delete)"
    echo "  -s: Azure subscription ID"
    echo "  -l: Azure location"

    exit 1
}

createStandardDeployment() {
    echo "Running standard deployment $deploymentName in subscription $subscriptionId in location $location."

    # Execute standard deployment
    az deployment sub create \
        --location "$location" \
        --name "$deploymentName" \
        --template-file "$bicepFilePath" \
        --parameters "$parametersFilePath" \
        --parameters envName="$environmentName" \
        --parameters location="$location"
}

deleteStandardDeployment() {
    echo "Standard deployment requires deleting the individual resource groups in the proper order."
    exit 1
}

createStackDeployment() {
    echo "Running stack deployment $deploymentName in subscription $subscriptionId in location $location."

    # Execute stack deployment
    az stack sub create \
        --name "$deploymentName" \
        --location "$location" \
        --template-file "$bicepFilePath" \
        --parameters "$parametersFilePath" \
        --parameters envName="$environmentName" \
        --parameters location="$location" \
        --action-on-unmanage deleteAll \
        --deny-settings-mode none
}

deleteStackDeployment() {
    echo "Deleting stack deployment $deploymentName in subscription $subscriptionId in location $location."

    # Execute stack delete
    az stack sub delete \
        --name "$deploymentName" \
        --action-on-unmanage deleteAll \
        --yes
}

# Parse command-line arguments
while getopts "t:m:s:l:n:" opt; do
    case $opt in
    t) deploymentType="$OPTARG" ;;
    m) deploymentMode="$OPTARG" ;;
    s) subscriptionId="$OPTARG" ;;
    l) location="$OPTARG" ;;
    n) environmentName="$OPTARG" ;;
    *) usage ;;
    esac
done

if [ -z "$subscriptionId" ]; then
    subscriptionId=$(az account show --query "id" -o tsv)
fi

# Validate required parameters
if [[ -z "$deploymentType" || -z "$deploymentMode" || -z "$subscriptionId" || -z "$location" || -z "$environmentName" ]]; then
    usage
fi

# Set the subscription (if not already set)
az account set --subscription "$subscriptionId"

deploymentName="deploy-${environmentName}"

if [[ "$deploymentMode" == "create" ]]; then
    if [[ "$deploymentType" == "standard" ]]; then
        createStandardDeployment
    elif [[ "$deploymentType" == "stack" ]]; then
        createStackDeployment
    else
        echo "Invalid deployment type. Must be 'standard' or 'stack'."
        exit 1
    fi
elif [[ "$deploymentMode" == "delete" ]]; then
    if [[ "$deploymentType" == "standard" ]]; then
        deleteStandardDeployment
    elif [[ "$deploymentType" == "stack" ]]; then
        deleteStackDeployment
    else
        echo "Invalid deployment type. Must be 'standard' or 'stack'."
        exit 1
    fi
else
    echo "Invalid deployment mode. Must be 'create' or 'delete'."
    exit 1
fi

echo "Done!"
exit 0
