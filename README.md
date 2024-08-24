# EKS Task Manager Flask

## Overview
This repository showcases a comprehensive DevOps pipeline designed to deploy a scalable Flask-based task management application on AWS. The project integrates Docker for containerization, Terraform for infrastructure provisioning, Jenkins for CI/CD automation, and AWS CloudWatch for monitoring and logging.

## Key Technologies
- **Amazon EKS (Elastic Kubernetes Service):** A managed Kubernetes service that simplifies the deployment, management, and scaling of containerized applications.
- **Docker:** A platform used to containerize the Flask application, ensuring consistency across different environments.
- **Terraform:** An Infrastructure-as-Code (IaC) tool that automates the provisioning and management of AWS resources.
- **Jenkins:** An automation server that facilitates continuous integration and continuous deployment (CI/CD) for the application and infrastructure.
- **AWS CloudWatch:** A monitoring service that collects logs and metrics from the EKS cluster, aiding in operational visibility.

## Architecture Components
### 1. **Amazon EKS Cluster**
   - **Hosted in:** Private subnets within a VPC.
   - **Features:** Managed control plane, scalable node groups, and secure access via IAM roles.

### 2. **VPC and Networking**
   - **Components:**
     - **Public Subnets:** For internet-facing services.
     - **Private Subnets:** For internal services and databases.
     - **Internet Gateway (IGW):** Provides internet access to public subnets.
     - **NAT Gateway:** Allows private subnets to access the internet securely.
     - **Route Tables:** Direct traffic within the VPC.

### 3. **ECR (Elastic Container Registry)**
   - **Purpose:** A secure, scalable repository for Docker images of the Flask application.

### 4. **DynamoDB**
   - **Purpose:** A highly available and performant NoSQL database used to store task data.

### 5. **CloudWatch**
   - **Integration:**
     - **DaemonSet:** Deploys the CloudWatch agent across EKS nodes for log collection.
     - **ConfigMap:** Defines CloudWatch agent configurations for monitoring and logging.

## Repository Structure
### **Flask App**
   - `app.py`: The core application code.
   - `requirements.txt`: List of dependencies for the Flask application.
   - `Dockerfile`: Defines the environment for containerizing the Flask application.
   - `Templates/index.html`: The HTML template for the user interface.

### **Infra**
   - `provider.tf`: AWS provider configuration for Terraform.
   - `vpc.tf`: Configuration for VPC and networking.
   - `iam.tf`: IAM roles and policies for secure access.
   - `eks.tf`: Configuration for setting up the EKS cluster.
   - `ecr.tf`: Configuration for creating the ECR repository.
   - `dynamodb.tf`: Configuration for the DynamoDB table.

### **Manifest**
   - `deployment.yml`: Kubernetes deployment configuration for the application.
   - `service.yml`: Kubernetes service configuration to expose the application.
   - `cloudwatch-agent-daemonset.yml`: Configuration for deploying CloudWatch agent DaemonSet.
   - `cloudwatch-agent-configmap.yml`: Configuration for the CloudWatch agent.

### **CI/CD**
   - `Jenkinsfile.app`: Jenkins pipeline for building, pushing, and deploying the Docker image.
   - `Jenkinsfile.infra`: Jenkins pipeline for provisioning and managing AWS infrastructure.

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests to enhance this project.





