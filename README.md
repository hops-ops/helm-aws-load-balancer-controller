# helm-aws-load-balancer-controller

A Crossplane Configuration package that installs the AWS Load Balancer Controller Helm chart with a minimal, stable interface.

## Overview

`helm-aws-load-balancer-controller` renders a single Helm release for the AWS Load Balancer Controller. It exposes only the inputs needed for chart values, namespace, and release name, keeping the interface stable while allowing full Helm overrides.

The AWS Load Balancer Controller manages AWS Elastic Load Balancers for Kubernetes Ingress and Service resources.

## Features

- **Minimal Helm interface**: values and overrideAllValues with stable defaults
- **Required clusterName**: The chart requires the EKS cluster name
- **Default namespace**: Installs to `kube-system` by default
- **GitOps friendly**: Ships a `.gitops/` deploy chart

## Prerequisites

- Crossplane installed in the cluster
- Crossplane providers:
  - `provider-helm` (>=v1.0.2)
- Crossplane function:
  - `function-auto-ready` (>=v0.6.0)
- AWS Load Balancer Controller requires IAM permissions via IRSA or Pod Identity

## Quick Start

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: helm-aws-load-balancer-controller
spec:
  package: ghcr.io/hops-ops/helm-aws-load-balancer-controller:latest
```

```yaml
apiVersion: helm.aws.hops.ops.com.ai/v1alpha1
kind: LoadBalancerController
metadata:
  name: aws-load-balancer-controller
  namespace: example-env
spec:
  clusterName: my-eks-cluster
  values:
    serviceAccount:
      create: true
      name: aws-load-balancer-controller
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/AWSLoadBalancerControllerRole
```

## Configuration Options

| Field | Description | Default |
|-------|-------------|---------|
| `clusterName` | Name of the EKS cluster (required) | - |
| `namespace` | Namespace for the Helm release | `kube-system` |
| `name` | Helm release name | XR metadata.name |
| `providerConfigRef` | Reference to Helm ProviderConfig | `{name: clusterName, kind: ProviderConfig}` |
| `labels` | Labels applied to all resources | `{hops.ops.com.ai/managed: "true"}` |
| `values` | Helm values merged with defaults | `{}` |
| `overrideAllValues` | Helm values replacing all defaults | `{}` |

## Default Values

The chart is installed with these default values:

```yaml
fullnameOverride: aws-load-balancer-controller
nameOverride: aws-load-balancer-controller
clusterName: <from spec.clusterName>
```

## Development

```bash
make render
make validate
make test
```
