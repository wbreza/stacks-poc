# Deployment Stacks POC

## Issues

Complex ARM deployments that performed at the subscription level with multiple resource groups are difficult to remove properly and in a deterministic way.

## Example

Create an Azure Container App with a virtual network created in a separate resource groups:

### `net` group

Contains a virtual network with subnet

### `env` group

Contains the container apps environment leveraging the virtual network

### `app` group

Contains the container app resource and leveraging the container apps environment

## Standard Deployment

Standard ARM deployment using Bicep/ARM work fine.
Multiple resource groups are created and the relevant resources are created within each group

Deleting the resources becomes difficult.
The groups need to be deleted in the following order:

1. `app` group
2. `env` group
3. `net` group

If they are deleted out of order the deletion will fail because the resource is still in use.

In order to determine the correct order for resource group deletion you would need to traverse the resource hierarchy of all the resources, following any dependency graph and order the resource groups in the correct order.

## Stack Deployment

Deployment stacks sit on top of current ARM deployments.
The deployment stack tracks all the resource groups and resources that exist within the stack.
All resources can be easily deleted in the proper order by deleting the deployment stack with the `--action-on-unmanage deleteAll` argument.

### Benefits

- Ability to query resources that exist within the deployment stack
- Ability to delete all resource groups / resources associated with deployment stack with proper ordering
- Ability to lock resources from modification if desired
- Ability to choose how resources are handled when stack is deleted
  - Detach: Leave resources intact but disassociate them from the stack
  - Delete: Delete resources but detach resource groups
  - DeleteAll: Delete all resource groups and resources
- Resources no longer existing in the stack are automatically deleted
  - Renamed, orphaned or no longer in the bicep

- `azd` will know exactly which resources were created based on its own provisioning
- `azd` can better support deploying into existing resource groups grouping its resources within a dedicated stack
- `azd` can easily cleanup/delete resources no matter the complexity of deployment

## Running this sample

The following script performs a standard bicep deployment using the `az cli` with 2 different flavors
- Standard deployment using `az deployment sub create`
- Stack deployment using `az stack sub create`

Execute the following script `./scripts/run.sh`

- `-n` The environment name added to create unique resources (**Required**)
- `-t` The deployment type (**stack or standard**)
- `-m` The deployment mode (**create or delete**)
- `-s` The azure subscription id (**defaults to current account**)
- `-l` The azure location to use (**defaults to `eastus2`**)

### Examples

#### Create a stacks deployment
```bash
./scripts/run.sh -n stacks-poc -t stacks -m create
```

#### Delete a stacks deployment
```bash
./scripts/run.sh -n stacks-poc -t stacks -m delete
```

#### Create s standard deployment
```bash
./scripts/run.sh -n stacks-poc -t standard -m create
```

#### Delete s standard deployment
```bash
./scripts/run.sh -n stacks-poc -t standard -m delete
```
