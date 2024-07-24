# Deployment Stacks POC

## Issues

Complex ARM deployments that performed at the subscription level with multiple resource groups are difficult to remove properly and in a deterministic way.

## Example

Create an Azure Container App with a virtual network created in a seperate resoruce group:

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

## Running this sample

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
