# Deploy Machine Learning Pipeline on Google Kubernetes Engine
#### A beginner’s guide to train and deploy machine learning pipelines in Python using PyCaret

## 👉 Learning Goals of this Tutorial
- What is a Container, What is Docker, What is Kubernetes, and What is Google Kubernetes Engine?
- Build a Docker image and upload it on Google Container Registry (GCR).
- Create clusters and deploy machine learning pipeline with Flask app as a web service.
- See a web app in action that uses a trained machine learning pipeline to predict on new data points in real-time.

Read the complete post: https://medium.com/@moez_62905/deploy-machine-learning-model-on-google-kubernetes-engine-94daac85108b

---

## 🐳 Docker Image Naming & Building

Unlike settings inside a `Dockerfile`, the name of a Docker image is defined **explicitly during the building stage** using the `-t` (tag) flag (or via GCP commands).

### 1. Naming Conventions for Local Builds
When building locally, you can specify any image name and tag:
```bash
docker build -t pycaret-google-app:latest .
```
* **`pycaret-google-app`:** The custom name of your image.
* **`latest`:** The version tag.

### 2. Naming Conventions for Google Container Registry (GCR)
To deploy containers on Google Cloud (e.g., GKE or Cloud Run), the image must be stored in Google Container Registry (GCR). GCR requires a strict URL-based naming path:
```
gcr.io/<GCP_PROJECT_ID>/<IMAGE_NAME>:<TAG>
```
* **`gcr.io`:** Google's container registry host address.
* **`<GCP_PROJECT_ID>`:** Your actual Google Cloud Project ID (e.g., `my-mlops-project-12345`).
* **`<IMAGE_NAME>`:** Your choice of application name (e.g., `pycaret-insurance-app`).

#### Example Local Build for GCR:
```bash
docker build -t gcr.io/my-mlops-project-12345/pycaret-insurance-app:latest .
```

### 3. Building Directly in the Cloud (Google Cloud Build)
Instead of building locally, you can submit the code directory directly to Google Cloud Build, which builds and automatically registers the image on the cloud:
```bash
gcloud builds submit --tag gcr.io/my-mlops-project-12345/pycaret-insurance-app:latest
```

---

## 🚀 Deployment through Google Cloud Kubernetes (GKE)

Here are the corrected, step-by-step commands to deploy your application on Google Kubernetes Engine (GKE) using your GCP project ID `pycaret-deployment-practice`. 

These commands fix multiple syntax bugs from the original instructions (such as variable case mismatch, tag spacing, incorrect zone naming, and deployment image flags):

```bash
# 1. Clone the repository and navigate into it
git clone https://github.com/pycaret/pycaret-deployment-google.git
cd pycaret-deployment-google/

# 2. Set the GCP Project ID environment variable (Note: Variable names in Linux are case-sensitive)
export PROJECT_ID=pycaret-deployment-practice
echo $PROJECT_ID

# 3. Build the Docker image
# Fixes: Removed the invalid space before 'v1' tag, and added '.' at the end for build context.
docker build -t gcr.io/${PROJECT_ID}/insurance-app:v1 .

# 4. Verify your local images
docker images

# 5. Authenticate Docker with Google Container Registry (GCR)
gcloud auth configure-docker gcr.io --quiet

# 6. Push the image to GCR
# Fix: Removed the invalid space before 'v1' tag.
docker push gcr.io/${PROJECT_ID}/insurance-app:v1

# 7. Set your default compute zone
# Fix: Corrected the spelling from 'us-centrall' to the valid zone 'us-central1-a'.
gcloud config set compute/zone us-central1-a

# 8. Create a Kubernetes cluster on GKE (Google Kubernetes Engine)
gcloud container clusters create insurance-cluster --num-nodes=1

# 9. Get credentials for your cluster to allow kubectl commands
gcloud container clusters get-credentials insurance-cluster

# 10. Deploy the application to the cluster
# Fixes: Corrected '--image-gcr.io' to '--image=gcr.io' and removed the space before the tag.
kubectl create deployment insurance-app --image=gcr.io/${PROJECT_ID}/insurance-app:v1

# 11. Expose the deployment to the internet as a LoadBalancer service
# (This assigns a public IP to your application on port 80, forwarding traffic to the container port 8080)
kubectl expose deployment insurance-app --type=LoadBalancer --port=80 --target-port=8080

# 12. Check service status to find your External IP (Note: External IP provisioning takes 1-2 minutes)
kubectl get service insurance-app
```

---

- Official : https://www.pycaret.org

- LinkedIn : https://www.linkedin.com/company/pycaret/

- YouTube : https://www.youtube.com/channel/UCxA1YTYJ9BEeo50lxyI_B3g 

- PyCaret's Repository : https://www.github.com/pycaret/pycaret
