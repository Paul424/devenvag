# Cert manager

This is just the default deployment manifests from [link](https://github.com/cert-manager/cert-manager/releases/download/v1.20.3/cert-manager.yaml) see also [cert-manager](https://cert-manager.io/docs/installation/).

## Trust-manager

Cert-managers trust-manager is added to publish CA's to a public endpoint.

```
helm template trust-manager --namespace cert-manager oci://quay.io/jetstack/charts/trust-manager --values ./config/cert-manager/values-trust-manager.yaml > trust-manager.yaml
```