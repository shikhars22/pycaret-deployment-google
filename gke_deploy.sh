#!/bin/bash
set -e

# ==============================================================================
# GKE ONE-SHOT DEPLOYMENT SCRIPT FOR PYCARET INSURANCE APP
# ==============================================================================

# 1. Define configuration variables
export PROJECT_ID=${GOOGLE_CLOUD_PROJECT:-pycaret-deployment-practice}
export REGION=us-central1
export ZONE=us-central1-a
export REPO_NAME=pycaret-repo
export CLUSTER_NAME=insurance-cluster
export DEPLOYMENT_NAME=insurance-app

echo "=========================================================="
echo "Starting GKE deployment for project: $PROJECT_ID"
echo "Region: $REGION, Zone: $ZONE"
echo "Artifact Registry: $REPO_NAME"
echo "=========================================================="

# 2. Enable GCloud APIs for GKE and Artifact Registry
echo "Enabling necessary Google Cloud APIs (Artifact Registry & container)..."
gcloud services enable artifactregistry.googleapis.com container.googleapis.com

# 3. Create the Artifact Registry Docker repository (if it doesn't already exist)
if ! gcloud artifacts repositories describe ${REPO_NAME} --location=${REGION} &>/dev/null; then
    echo "Creating Artifact Registry repository '${REPO_NAME}'..."
    gcloud artifacts repositories create ${REPO_NAME} \
        --repository-format=docker \
        --location=${REGION} \
        --description="Docker repository for PyCaret deployment"
else
    echo "Artifact Registry repository '${REPO_NAME}' already exists."
fi

# 4. Authenticate Docker client with the Artifact Registry region
echo "Configuring Docker authentication..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# 5. Build the Docker container image
IMAGE_TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${DEPLOYMENT_NAME}:v1"
echo "Building Docker image: $IMAGE_TAG..."
docker build -t ${IMAGE_TAG} .

# 6. Push the image to Artifact Registry
echo "Pushing Docker image to Artifact Registry..."
docker push ${IMAGE_TAG}

# 7. Set default compute zone
gcloud config set compute/zone ${ZONE}

# 8. Create GKE Cluster (if it doesn't already exist)
if ! gcloud container clusters describe ${CLUSTER_NAME} --zone=${ZONE} &>/dev/null; then
    echo "Creating GKE Cluster '${CLUSTER_NAME}' (this can take 5 to 10 minutes)..."
    gcloud container clusters create ${CLUSTER_NAME} --num-nodes=1 --zone=${ZONE}
else
    echo "GKE Cluster '${CLUSTER_NAME}' already exists."
fi

# 9. Fetch cluster access credentials for kubectl
echo "Fetching GKE cluster credentials..."
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone=${ZONE}

# 10. Deploy the application image to GKE
if ! kubectl get deployment ${DEPLOYMENT_NAME} &>/dev/null; then
    echo "Deploying application to GKE..."
    kubectl create deployment ${DEPLOYMENT_NAME} --image=${IMAGE_TAG}
else
    echo "Updating existing GKE deployment with the new image..."
    kubectl set image deployment/${DEPLOYMENT_NAME} ${DEPLOYMENT_NAME}=${IMAGE_TAG}
fi

# 11. Expose deployment as a LoadBalancer service (assigns a public IP)
if ! kubectl get service ${DEPLOYMENT_NAME} &>/dev/null; then
    echo "Exposing deployment as a public LoadBalancer service on port 80..."
    kubectl expose deployment ${DEPLOYMENT_NAME} --type=LoadBalancer --port=80 --target-port=8080
else
    echo "GKE Service already exposed."
fi

# 12. Poll until the GKE LoadBalancer IP has been allocated and display url
echo "Waiting for External IP allocation (this takes 1-2 minutes)..."
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
    EXTERNAL_IP=$(kubectl get svc ${DEPLOYMENT_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    if [ -z "$EXTERNAL_IP" ]; then
        echo -n "."
        sleep 10
    fi
done
echo ""

echo "=========================================================="
echo "DEPLOYMENT COMPLETE!"
echo "Access your PyCaret application at: http://$EXTERNAL_IP"
echo "=========================================================="
