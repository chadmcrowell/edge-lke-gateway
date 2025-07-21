# Edge-LKE Gateway

This project demonstrates how to use Akamai EdgeWorkers as an API gateway with token authentication in front of a Linode Kubernetes Engine (LKE) backend.

## Structure

- `edgeworker/`: EdgeWorker JavaScript and metadata
- `terraform/`: Terraform code to provision LKE cluster
- `kubernetes/`: Ingress resource to expose API
