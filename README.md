# Deploy Machine Learning Pipeline on Google Kubernetes Engine
#### A beginner’s guide to train and deploy machine learning pipelines in Python using PyCaret

## 👉 Learning Goals of this Tutorial
- What is a Container, What is Docker, What is Kubernetes, and What is Google Kubernetes Engine?
- Build a Docker image and upload it on Google Container Registry (GCR).
- Create clusters and deploy machine learning pipeline with Flask app as a web service.
- See a web app in action that uses a trained machine learning pipeline to predict on new data points in real-time.

Read the complete post: https://medium.com/@moez_62905/deploy-machine-learning-model-on-google-kubernetes-engine-94daac85108b

---

## 🐳 Docker Image Naming & Building (Artifact Registry)

Unlike settings inside a `Dockerfile`, the name of a Docker image is defined **explicitly during the building stage** using the `-t` (tag) flag (or via GCP commands).

Since Google Container Registry (GCR) is retired, Google Cloud uses **Artifact Registry (GAR)** to store container images. Artifact Registry requires a strict URL-based naming path:

```
<LOCATION>-docker.pkg.dev/<GCP_PROJECT_ID>/<REPO_NAME>/<IMAGE_NAME>:<TAG>
```
* **`<LOCATION>`:** The GCP region (e.g., `us-central1` or `asia-east1`).
* **`<GCP_PROJECT_ID>`:** Your actual Google Cloud Project ID (e.g., `pycaret-deployment-practice`).
* **`<REPO_NAME>`:** The name of your Artifact Registry repository (e.g., `pycaret-repo`).
* **`<IMAGE_NAME>`:** Your choice of application name (e.g., `insurance-app`).

#### Example Local Build for Artifact Registry:
```bash
docker build -t us-central1-docker.pkg.dev/pycaret-deployment-practice/pycaret-repo/insurance-app:v1 .
```

### Building Directly in the Cloud (Google Cloud Build)
Instead of building locally, you can submit the code directory directly to Google Cloud Build, which builds and automatically registers the image on the cloud:
```bash
gcloud builds submit --tag us-central1-docker.pkg.dev/pycaret-deployment-practice/pycaret-repo/insurance-app:v1
```

---

## 🚀 Deployment through Google Cloud Kubernetes (GKE)

Here are the corrected, step-by-step commands to deploy your application on Google Kubernetes Engine (GKE) using your GCP project ID `pycaret-deployment-practice`.

These commands configure and use **Google Artifact Registry** to store the container image instead of the deprecated `gcr.io`:

```bash
# 1. Clone the repository and navigate into it
git clone https://github.com/shikhars22/pycaret-deployment-google.git
cd pycaret-deployment-google/

# 2. Set environment variables (Note: Variable names in Linux are case-sensitive)
# In Cloud Shell, GOOGLE_CLOUD_PROJECT is already set for you:
export PROJECT_ID=${GOOGLE_CLOUD_PROJECT:-pycaret-deployment-practice}
export REGION=us-central1
export REPO_NAME=pycaret-repo
echo "Project: $PROJECT_ID, Region: $REGION, Repo: $REPO_NAME"

# 3. Create the Artifact Registry Docker repository (if it doesn't already exist)
gcloud artifacts repositories create ${REPO_NAME} \
    --repository-format=docker \
    --location=${REGION} \
    --description="Docker repository for PyCaret deployment"

# 4. Authenticate Docker with the Google Artifact Registry region
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# 5. Build the Docker image
docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/insurance-app:v1 .

# 6. Push the image to Artifact Registry
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/insurance-app:v1

# 7. Set your default compute zone
gcloud config set compute/zone ${REGION}-a

# 8. Create a Kubernetes cluster on GKE (Google Kubernetes Engine)
gcloud container clusters create insurance-cluster --num-nodes=1

# 9. Get credentials for your cluster to allow kubectl commands
gcloud container clusters get-credentials insurance-cluster

# 10. Deploy the application to GKE using the Artifact Registry image
kubectl create deployment insurance-app --image=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/insurance-app:v1

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
