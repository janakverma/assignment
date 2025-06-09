## Full Stack CI/CD Pipeline for a Python Web Application on Kubernetes

This project demonstrates a complete, automated CI/CD pipeline for a simple Python Flask web application. The application is containerized using Docker, pushed to AWS Elastic Container Registry (ECR), and deployed to a Kubernetes cluster (EKS) using GitHub Actions. The deployment includes a Horizontal Pod Autoscaler (HPA) to handle variable traffic loads.

---
### Project Architecture
**Infrastructure as Code:** AWS infrastructure (VPC, EKS, KMS) is provisioned using Terraform.
**Application:** A Python Flask app with a "Hello World" endpoint and a /healthz check.
**Containerization:** A Dockerfile to create a lightweight container image for the app.
**Container Registry:** AWS Elastic Container Registry (ECR) to store the Docker images.
**Orchestration:** An AWS Elastic Kubernetes Service (EKS) cluster to run the application.
**CI/CD:** A GitHub Actions workflow to automate the build, push, and deploy process.
**Autoscaling:** A Horizontal Pod Autoscaler (HPA) to automatically scale the application pods based on CPU load.

### Project Structure
```
.
├── .github/
│   └── workflows/
│     └── ci-cd.yml        # GitHub Actions CI/CD workflow
├── kubernetes/
│   ├── deployment.yml     # Kubernetes Deployment
│   ├── hpa.yml            # Kubernetes Horizontal Pod 
|   └── service.yml        # Kubernetes Service
├── terraform/             # Terraform files for infrastructure
│   ├── main.tf
│   ├── backend.tf
│   ├── s3_backend.tf
│   └── variables.tf
├── app.py                 # Python Flask application
├── Dockerfile             # Dockerfile for containerization
├── requirements.txt       # Python dependencies
├── .gitignore             # gitignore files to ignore unnecessary files
└── README.md              # README.md
```

---
#### 1. Infrastructure Setup
**Prerequisites**
***i)*** An AWS Account with sufficient permissions to create EKS and ECR resources.
***ii)*** Terraform installed.
***iii)*** AWS CLI installed and configured.
***iv)*** kubectl installed.
***v)*** Docker Desktop installed.

#### Steps to Provision
***a) Deploy Infrastructure with Terraform***
The AWS infrastructure is defined using Terraform. The configuration uses modules to create the VPC, the EKS cluster, and the necessary KMS keys for encryption.

***i)*** Navigate to the terraform directory:
```
cd terraform
```
***ii)*** Initialize the Terraform workspace. This will download the required providers and modules (vpc, eks, kms).
```
terraform init
```
***iii)*** Review the execution plan to see what resources will be created.
```
terraform plan
```
***iv)*** Apply the configuration to provision the infrastructure.
```
terraform apply
```

***b) Create an ECR Repository***
The pipeline needs a repository in ECR to push the Docker images to. You must create this manually before running the pipeline for the first time.

***i)*** Navigate to the Elastic Container Registry (ECR) service in the AWS Console.
***ii)*** Click Create repository.
***iii)*** Set "Visibility settings" to Private.
***iv)*** Enter a Repository name (e.g., b2cloud-assignment/app). This name must exactly match the value you will set in the ECR_REPOSITORY GitHub secret.
***v)*** Click Create repository.

---
#### 2. CI/CD Pipeline Setup (GitHub Actions)
The pipeline requires several secrets to be configured in your GitHub repository to securely access AWS and your Kubernetes cluster.

***Configure GitHub Secrets***

***i)*** Navigate to your repository's Settings > Secrets and variables > Actions and create the following Repository secrets:

a) Secret Name
b) Description
c) Example Value

```
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
Long hash value like "YXBpVmVyc2lvbF...."
```

To get the value for KUBE_CONFIG, first update your local kubeconfig file to connect to the new cluster created by Terraform, then run the base64 command.

***Update local kubeconfig to connect to the new EKS cluster***
Replace <region> and <cluster-name> with your values

```
aws eks update-kubeconfig --region eu-north-1 --name b2cloud-assignment --alias b2cloud-assignment
```

***Generate the base64 string***
```
cat ~/.kube/config | base64
```

#### 3. Running the CI/CD Pipeline
The pipeline is configured to run automatically whenever new code is pushed to the master branch.
Commit all your files (app.py, Dockerfile, kubernetes/, etc.) to your local repository.
Push the changes to your GitHub repository.
```
git add .
git commit -m "Initial project setup"
git push origin master
```
Navigate to the Actions tab in your GitHub repository to monitor the workflow's progress.

#### 4. Verification Steps
Once the pipeline has completed successfully, you can verify that the application is running and accessible.
**a) Verify the Deployment and Pods**
Check that the deployment was successful and that your pods are in the Running state.
***Check the status of your deployment***
```
kubectl get deployment b2cloud-assignment
```
***List the running pods***
```
kubectl get pods
```

**b) Access the Application**
The application is exposed via a LoadBalancer service. Find its external IP address.
***Get the service details, including the External IP***
```
kubectl get service b2cloud-assignment
```
Once you have the EXTERNAL-IP, you can access the application in your browser or using curl.
Replace "EXTERNAL_IP" with the IP address from the previous command.
```
curl http://aefeda491364147659c66f4f2fdac8c8-594221478.eu-north-1.elb.amazonaws.com
```
Expected Output: 
```
<h1>Hello, World!</h1><p>Welcome to this basic web application.</p>
```
Health Check:
```
curl http://aefeda491364147659c66f4f2fdac8c8-594221478.eu-north-1.elb.amazonaws.com/healthz
```
Expected Output: 
```
{"status":"ok"}
```

**c) Test the Horizontal Pod Autoscaler (HPA)**
Watch the HPA status in one terminal window:
kubectl get hpa b2cloud-assignment -w

Initially, you will see TARGETS as <unknown>/10% or 0%/10% with 1 replicas.

Generate load on the application from a second terminal:
Replace <EXTERNAL_IP> with your service's IP
```
while true; do curl http://aefeda491364147659c66f4f2fdac8c8-594221478.eu-north-1.elb.amazonaws.com; done
```

Observe the scaling action. After a few minutes, you will see the CPU usage in the first terminal climb past the 10% target, and the HPA will increase the number of REPLICAS up to the maximum of 5. When you stop the load generator, the replica count will automatically scale back down to 1.

#### 5. Problems Faced
I was not able to create a t3.medium instance type node group in eu-north-1 region for the b2cloud-assignment EKS cluster using terraform.
Looks like there is a policy in place that is forcing to create a t3a.micro instance type node-group which does not exits in the region.

Below is the decoded message error that I faced
```
"DecodedMessage": "{\"allowed\":false,\"explicitDeny\":true,\"matchedStatements\":{\"items\":[{\"statementId\":\"RequireMicroInstanceType\",\"effect\":\"DENY\",\"principals\":{\"items\":[{\"value\":\"AIDAZG2XYEL6VOGQ3VJ2H\"}]},\"principalGroups\":{\"items\":[]},\"actions\":{\"items\":[{\"value\":\"ec2:RunInstances\"}]},\"resources\":{\"items\":[{\"value\":\"arn:aws:ec2:*:*:instance/*\"}]},\"conditions\":{\"items\":[{\"key\":\"ec2:InstanceType\",\"values\":{\"items\":[{\"value\":\"t3a.micro\"}]}}]}}]},\"failures\":{\"items\":[]},\"context\":{\"principal\":{\"id\":\"AIDAZG2XYEL6VOGQ3VJ2H\",\"name\":\"Con.Janak.Verma\",\"arn\":\"arn:aws:iam::633154839293:user/Con.Janak.Verma\"},\"action\":\"RunInstances\",\"resource\":\"arn:aws:ec2:eu-north-1:633154839293:instance/*\",\"conditions\":{\"items\":[{\"key\":\"ec2:AvailabilityZoneId\",\"values\":{\"items\":[{\"value\":\"eun1-az3\"}]}},{\"key\":\"ec2:MetadataHttpPutResponseHopLimit\",\"values\":{\"items\":[{\"value\":\"2\"}]}},{\"key\":\"ec2:InstanceMarketType\",\"values\":{\"items\":[{\"value\":\"on-demand\"}]}},{\"key\":\"aws:Resource\",\"values\":{\"items\":[{\"value\":\"instance/*\"}]}},{\"key\":\"aws:Account\",\"values\":{\"items\":[{\"value\":\"633154839293\"}]}},{\"key\":\"ec2:AvailabilityZone\",\"values\":{\"items\":[{\"value\":\"eu-north-1c\"}]}},{\"key\":\"ec2:ebsOptimized\",\"values\":{\"items\":[{\"value\":\"false\"}]}},{\"key\":\"ec2:InstanceBandwidthWeighting\",\"values\":{\"items\":[{\"value\":\"default\"}]}},{\"key\":\"ec2:IsLaunchTemplateResource\",\"values\":{\"items\":[{\"value\":\"true\"}]}},{\"key\":\"ec2:InstanceType\",\"values\":{\"items\":[{\"value\":\"t3.medium\"}]}},{\"key\":\"ec2:RootDeviceType\",\"values\":{\"items\":[{\"value\":\"ebs\"}]}},{\"key\":\"aws:Region\",\"values\":{\"items\":[{\"value\":\"eu-north-1\"}]}},{\"key\":\"ec2:MetadataHttpEndpoint\",\"values\":{\"items\":[{\"value\":\"enabled\"}]}},{\"key\":\"ec2:InstanceMetadataTags\",\"values\":{\"items\":[{\"value\":\"disabled\"}]}},{\"key\":\"aws:Service\",\"values\":{\"items\":[{\"value\":\"ec2\"}]}},{\"key\":\"ec2:InstanceID\",\"values\":{\"items\":[{\"value\":\"*\"}]}},{\"key\":\"ec2:MetadataHttpTokens\",\"values\":{\"items\":[{\"value\":\"required\"}]}},{\"key\":\"aws:Type\",\"values\":{\"items\":[{\"value\":\"instance\"}]}},{\"key\":\"ec2:Tenancy\",\"values\":{\"items\":[{\"value\":\"default\"}]}},{\"key\":\"ec2:Region\",\"values\":{\"items\":[{\"value\":\"eu-north-1\"}]}},{\"key\":\"aws:ARN\",\"values\":{\"items\":[{\"value\":\"arn:aws:ec2:eu-north-1:633154839293:instance/*\"}]}},{\"key\":\"ec2:LaunchTemplate\",\"values\":{\"items\":[{\"value\":\"arn:aws:ec2:eu-north-1:633154839293:launch-template/lt-0b94d26ace70158e2\"}]}}]}}}"
```

This simly translates to 
```
"explicitDeny": true,
"statementId": "RequireMicroInstanceType",
"effect": "DENY",
"conditions": {
  "ec2:InstanceType": ["t3a.micro"]
}
```

Hence I had to manually create a node group and then deploy the workload.


#### 6. Summary
This was cool and good project that I liked to create and play around. There are many other ways that this could be improved and real world or in production, I would deploy an "Ingress-Nginx" and then have the SSL certificate in place with automation to update it before expiry. I would use a domain to configure the URLs.
Metrics monitoring using nodeexporter,prometheus and grafana could be stood up.
Application monitoring via filebeat/fluentd,logstash,elasticsearch and kibana can be setup.
So there are several other things that would be needed in real world but since this simply a mock test assignment, we should be good.

Please feel free to connect and ask if you have any queries.

Thank you !!