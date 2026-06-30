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

- Official : https://www.pycaret.org

- LinkedIn : https://www.linkedin.com/company/pycaret/

- YouTube : https://www.youtube.com/channel/UCxA1YTYJ9BEeo50lxyI_B3g 

- PyCaret's Repository : https://www.github.com/pycaret/pycaret
