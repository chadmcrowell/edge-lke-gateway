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

- `terraform/`: Terraform code to provision LKE cluster
- `kubernetes/`: Deployment, service, and envoy gateway with `HTTPRoute`


## Implementation Guide

This guide walks you through deploying an API gateway using **Envoy** in front of a **Linode Kubernetes Engine (LKE)** backend API. Ideal for low-latency, low-cost API delivery across LATAM.

---

### 📦 Prerequisites

#### 🔐 Accounts & Access

* [ ] Linode account with API token

#### 💻 Tools Installed

* `terraform`
* `kubectl`
* `docker` (if building backend images)
* `helm`

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

### measure latency

```bash
curl -w "\nConnect: %{time_connect}s\nTotal: %{time_total}s\n" \
  -H "Host: api.myapp.lat" http://172.233.4.110/api/healthz

```

This is the actual response body from your backend service — your /api/healthz endpoint is working.

⏱ Connect: 0.165102s
Time taken to establish the TCP connection to 172.233.4.110:
- Includes DNS resolution and the TCP handshake
- Fast connection suggests the NodeBalancer is reachable and healthy

⏱ Total: 0.557387s
Time from start to finish of the HTTP request:
- Includes TCP connection, sending the request, waiting for the response, and receiving it
- Useful to spot backend slowness or excessive network latency


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

