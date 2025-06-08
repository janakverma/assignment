Full Stack CI/CD Pipeline for a Python Web Application on Kubernetes
This project demonstrates a complete, automated CI/CD pipeline for a simple Python Flask web application. The application is containerized using Docker, pushed to AWS Elastic Container Registry (ECR), and deployed to a Kubernetes cluster (EKS) using GitHub Actions. The deployment includes a Horizontal Pod Autoscaler (HPA) to handle variable traffic loads.
Project Architecture
Infrastructure as Code: AWS infrastructure (VPC, EKS, KMS) is provisioned using Terraform.
Application: A Python Flask app with a "Hello World" endpoint and a /healthz check.
Containerization: A Dockerfile to create a lightweight container image for the app.
Container Registry: AWS Elastic Container Registry (ECR) to store the Docker images.
Orchestration: An AWS Elastic Kubernetes Service (EKS) cluster to run the application.
CI/CD: A GitHub Actions workflow to automate the build, push, and deploy process.
Autoscaling: A Horizontal Pod Autoscaler (HPA) to automatically scale the application pods based on CPU load.

Project Structure
.
├── .github/
│   └── workflows/
│       └── ci-cd.yml      # GitHub Actions CI/CD workflow
├── kubernetes/
│   ├── deployment.yml     # Kubernetes Deployment and Service
│   └── hpa.yml            # Kubernetes Horizontal Pod Autoscaler
├── terraform/             # Terraform files for infrastructure
│   ├── main.tf
│   └── ...
├── app.py                 # Python Flask application
├── Dockerfile             # Dockerfile for containerization
└── requirements.txt       # Python dependencies


1. Infrastructure Setup
Prerequisites
An AWS Account with sufficient permissions to create EKS and ECR resources.
Terraform installed.
AWS CLI installed and configured.
kubectl installed.
Docker Desktop installed.
Steps to Provision
a) Deploy Infrastructure with Terraform
The AWS infrastructure is defined using Terraform. The configuration uses modules to create the VPC, the EKS cluster, and the necessary KMS keys for encryption.
Navigate to the terraform directory:
cd terraform


Initialize the Terraform workspace. This will download the required providers and modules (vpc, eks, kms).
terraform init


Review the execution plan to see what resources will be created.
terraform plan


Apply the configuration to provision the infrastructure.
terraform apply


b) Create an ECR Repository
The pipeline needs a repository in ECR to push the Docker images to. You must create this manually before running the pipeline for the first time.
Navigate to the Elastic Container Registry (ECR) service in the AWS Console.
Click Create repository.
Set "Visibility settings" to Private.
Enter a Repository name (e.g., b2cloud-assignment/app). This name must exactly match the value you will set in the ECR_REPOSITORY GitHub secret.
Click Create repository.
2. CI/CD Pipeline Setup (GitHub Actions)
The pipeline requires several secrets to be configured in your GitHub repository to securely access AWS and your Kubernetes cluster.
Configure GitHub Secrets
Navigate to your repository's Settings > Secrets and variables > Actions and create the following Repository secrets:
Secret Name
Description
Example Value
AWS_ACCESS_KEY_ID
The access key ID for an AWS IAM user with ECR and EKS permissions.
AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY
The secret access key for the same IAM user.
wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_REGION
The AWS region where your ECR repository and EKS cluster are located.
eu-north-1
ECR_REPOSITORY
The name of your ECR repository (name only, not the full URL).
b2cloud-assignment/app
KUBE_CONFIG
The base64-encoded content of your kubeconfig file to allow access to your cluster.
(Generated from the command below)

To get the value for KUBE_CONFIG, first update your local kubeconfig file to connect to the new cluster created by Terraform, then run the base64 command.
# Update local kubeconfig to connect to the new EKS cluster
# Replace <region> and <cluster-name> with your values
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Generate the base64 string
cat ~/.kube/config | base64


3. Running the CI/CD Pipeline
The pipeline is configured to run automatically whenever new code is pushed to the master (or main) branch.
Commit all your files (app.py, Dockerfile, kubernetes/, etc.) to your local repository.
Push the changes to your GitHub repository.
git add .
git commit -m "Initial project setup"
git push origin master


Navigate to the Actions tab in your GitHub repository to monitor the workflow's progress.
4. Verification Steps
Once the pipeline has completed successfully, you can verify that the application is running and accessible.
a) Verify the Deployment and Pods
Check that the deployment was successful and that your pods are in the Running state.
# Check the status of your deployment
kubectl get deployment hello-world-deployment

# List the running pods
kubectl get pods


b) Access the Application
The application is exposed via a LoadBalancer service. Find its external IP address.
# Get the service details, including the External IP
kubectl get service hello-world-service


Once you have the EXTERNAL-IP, you can access the application in your browser or using curl.
# Replace <EXTERNAL_IP> with the IP address from the previous command
curl http://<EXTERNAL_IP>
# Expected Output: <h1>Hello, World!</h1>

curl http://<EXTERNAL_IP>/healthz
# Expected Output: {"status":"ok"}


c) Test the Horizontal Pod Autoscaler (HPA)
Watch the HPA status in one terminal window:
kubectl get hpa hello-world-hpa -w

Initially, you will see TARGETS as <unknown>/50% or 0%/50% with 2 replicas.
Generate load on the application from a second terminal:
# Replace <EXTERNAL_IP> with your service's IP
while true; do curl http://<EXTERNAL_IP>; done


Observe the scaling action. After a few minutes, you will see the CPU usage in the first terminal climb past the 50% target, and the HPA will increase the number of REPLICAS up to the maximum of 5. When you stop the load generator, the replica count will automatically scale back down to 2.
