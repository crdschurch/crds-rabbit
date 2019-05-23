# Rabbitmq for Crossroads

This repository contains the helm chart for rabbitmq-ha. This was forked from the original: https://github.com/helm/charts/tree/master/stable/rabbitmq-ha

# Team City

This repository is automatically built and deployed via team city. If you need to deploy a new rabbit cluster you should access the builds on teamcity and deploy that way.

If you want to learn more - read on

# Generating Kubernetes Manifests

- If you do not have helm installed you must install it: https://helm.sh/docs/using_helm/ - I use homebrew. NOTE: You do NOT actually need to run `helm init` as you do not need to hook it up to the k8s cluster to generate the manifests.

### Shell Script With Vault Credentials

Run `./generate_manifests.sh <role_id> <secret_id> <crds_env: {int, demo, prod}>

### No Vault
- Create a folder in the root of this repo. Example: `mkdir manifests`.

- Run the following command, replacing any secret or username values you'd like. You can also ommit the secrets and they will be automatically generated. Make sure you do not commit the `secret.yaml` manifest to github as it contains secrets.

`helm template --output-dir manifests --set rabbitmqUsername=admin,rabbitmqPassword=secretpassword,managementPassword=anothersecretpassword,rabbitmqErlangCookie=secretcookie,fullnameOverride=crds-rabbit  helm-chart/`

# Deploying the generated manifests

Run `kubectl apply -f ./manifests`. This will apply all the manifests in the folder.

# Production Readiness

This rabbitmq setup does not solve for multi-tenancy. The cluster is set up with a single vhost and a single user. Best practices suggest setting up a vhost and user per project per environment. This chart can be modified to do this but it was outside the scope of the original installation. To do so you must modify the `definitions` in the `values.yaml` file of the helm-chart to include other users and vhosts. The current definitions come from the `_helpers.tpl` file in the helm-chart. Look for `rabbitmq-ha.definitions`.