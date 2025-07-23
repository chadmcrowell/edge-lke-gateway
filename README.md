# Edge-LKE Gateway

This project demonstrates how to use Akamai EdgeWorkers as an API gateway with token authentication in front of a Linode Kubernetes Engine (LKE) backend.

This setup simulates EdgeWorker behavior by using Envoy Gateway + Gateway API filters to apply custom request logic at the gateway layer, just like EdgeWorkers apply logic at the Akamai edge.

Your HTTPRoute includes this:
```yaml
filters:
  - type: RequestHeaderModifier
    requestHeaderModifier:
      set:
        - name: X-Envoy-Validated
          value: "true"
```
This is equivalent to an EdgeWorker modifying the request to inject metadata before sending it upstream.


## Structure

- `edgeworker/`: EdgeWorker JavaScript and metadata
- `terraform/`: Terraform code to provision LKE cluster
- `kubernetes/`: Ingress resource to expose API


## Implementation Guide

This guide walks you through deploying an edge-validated API gateway using **Akamai EdgeWorkers** in front of a **Linode Kubernetes Engine (LKE)** backend API. Ideal for low-latency, low-cost API delivery across LATAM.

---

### 📦 Prerequisites

#### 🔐 Accounts & Access

* [ ] Akamai developer account (EdgeWorker access enabled)
* [ ] Linode account with API token
* [ ] Domain name (e.g. `myapp.lat`) with DNS control
* [ ] Public SSL cert (Let’s Encrypt or Akamai cert manager)

#### 💻 Tools Installed

* `terraform`
* `kubectl`
* `akamai` CLI with `edgeworkers` and `property-manager` plugins
* `docker` (if building backend images)
* `helm` (optional)

---

### 🛠️ Step 1: Provision LKE Cluster

1. Set your Linode token as a variable:

```bash
export TF_VAR_linode_token=your-token-here
```

2. Deploy the cluster:

```bash
cd terraform
terraform init
terraform apply
```

3. Save the kubeconfig and test access:

```bash
terraform output -raw kubeconfig > ~/.kube/latam-kubeconfig.yaml

export KUBECONFIG=~/.kube/latam-kubeconfig.yaml

kubectl get nodes
```

---

### ⚙️ STEP 2: Deploy Envoy Gateway

```bash
# https://gateway.envoyproxy.io/latest/install/install-helm/

helm install eg oci://docker.io/envoyproxy/gateway-helm \
  --version v0.0.0-latest \
  -n envoy-gateway-system --create-namespace


```
> This will create a Service of type LoadBalancer, and Linode will automatically provision a NodeBalancer.


### ⚙️ STEP 3: Deploy Your API Backend

1. Create a simple API (Node.js, Go, etc.) and expose it as a Kubernetes service.

2. Apply the sample manifests:

```bash
kubectl apply -f ../kubernetes/deployment.yaml

kubectl apply -f ../kubernetes/envoy-gw-and-httproute.yaml
```

3. Verify public access:

```bash
k -n envoy-gateway-system get svc

curl -H "Host: api.myapp.lat" http://172.233.4.110/api/healthz 


```

---

### 🌐 Step 4: Setup Akamai EdgeWorker

1. Log in to Akamai CLI:

```bash
akamai configure

akamai install edgeworkers
```

2. Package and upload EdgeWorker:

```bash
cd ../edgeworker
akamai edgeworkers pack
akamai edgeworkers upload --bundle bundle.tgz --edgeworker-id YOUR_ID
```

3. Activate the EdgeWorker in your environment (staging or production):

```bash
akamai edgeworkers activate --network staging --edgeworker-id YOUR_ID
```

---

### 🌍 Step 4: Configure Akamai Property

1. In **Property Manager**, create or update your property:
   * Match rule: `/api/*`
   * Add **EdgeWorker behavior** and attach your uploaded script
   * Set **origin hostname**: `api.myapp.lat`

2. Add `Authorization` and `x-forwarded-for` headers to origin request.

3. Deploy the property to staging, then production.

---

### 🔐 Step 5: Secure Traffic

* Use HTTPS for origin and edge (Let's Encrypt or Akamai cert).
* Optionally:
  * Validate JWT signatures inside EdgeWorker
  * Enforce IP geo-blocking using `request.userLocation`

---

### 📈 Observability & Tuning

* Enable **DataStream** in Akamai to stream logs
* Add rate limiting using EdgeKV
* Tune token cache TTL and validation method

---

### 🧪 Test

1. Make an API call with and without a valid `Authorization: Bearer ...` header:

```bash
curl -H "Authorization: Bearer fake" https://myapp.lat/api/ping
```

2. Check:
   * 401s are blocked at edge
   * Valid tokens forward to LKE backend

---

## 📌 Notes for LATAM Deployments

* Use LKE in **São Paulo (`br-gru`)** for lowest latency
* Akamai Edge PoPs exist in **Bogotá, Santiago, Lima, Buenos Aires, and Mexico City**
* This ensures end users hit edge logic in-country before ever reaching the cloud

---

## 📚 Next Steps

* Add API token revocation with EdgeKV
* Add caching with `cacheKey` logic in EdgeWorker
* Add OpenTelemetry in LKE backend for tracing

