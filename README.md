# Valavaxyconsultancyapi

# Follow these steps to setup and deploy java app to k8s

aws --version
kubectl version --client
eksctl version
eksctl version


# Step 1 Attaching the IAM Role to an EC2 Instance
To attach an IAM role to an EC2 instance for EKS management:

Create the IAM Role:

Navigate to the IAM service in the AWS Management Console.
Create a new role and select AWS service as the type of trusted entity, choosing EC2 as the service that will use this role.

Attach policies that grant permissions needed to manage EKS. Common policies include:
just give admin access 
Attach the Role to the EC2 Instance:
Go to the EC2 dashboard in the AWS Management Console.
Find the EC2 instance that you use as your management node.
Select the instance, then click on Actions > Security > Modify IAM role.
Select the IAM role you created from the drop-down menu and apply the changes.
Configuring the Instance
Once the IAM role is attached:

Any AWS CLI or SDK tool running on the instance will automatically use the credentials provided by the IAM role.
You won’t need to manually configure AWS credentials on the instance, enhancing security by not storing sensitive information on the instance.


eksctl create cluster --name ezlearn-cluster --region us-east-1 --node-type t3.medium --nodes 2

After the cluster is created, update your kubeconfig file to ensure kubectl can interact with your new cluster:


aws eks --region us-east-1 update-kubeconfig --name ezlearn-cluster

Step 1: Prepare Your Amazon EKS Cluster

First, ensure your EKS cluster is ready.







# Step 2: Install and Configure Jenkins

# Install Jenkins:

Download and install Jenkins on a suitable server. You can find the latest Jenkins package for your operating system at Jenkins.io.

Install Necessary Plugins:

Navigate to Manage Jenkins > Manage Plugins > Available and install these plugins:

Git plugin – for source code management.

Maven Integration plugin – for building Java applications.
Docker Pipeline – for Docker operations.
Kubernetes CLI Plugin – to interact with your Kubernetes cluster.

Configure Jenkins Tools:
Go to Manage Jenkins > Global Tool Configuration.
Set up Maven, JDK, and any other tools you may need.

# Step 3: Add Required Credentials in Jenkins
Add Credentials:
Go to Manage Jenkins > Manage Credentials > Jenkins > Global credentials (unrestricted) > Add Credentials.
Add credentials for your Git repository, Docker Hub, and a kubeconfig for Kubernetes:
Git credentials: Username with password.
Docker Hub credentials: Username with password.
Kubeconfig: Use the Secret file type to upload your kubeconfig file.
Retrieve the Kubeconfig File
Default Location: By default, the kubeconfig entries are stored in the ~/.kube/config file on your machine. You can copy this file or reference it directly.

Using the Kubeconfig in Jenkins
Once you have your kubeconfig file:

Upload to Jenkins:
Go to Manage Jenkins > Manage Credentials > Jenkins > Global credentials (unrestricted) > Add Credentials.
Choose Secret file as the type.
Upload your kubeconfig file.
Assign an ID that you can refer to in your Jenkins jobs.

# Step 4: Create a Jenkins Job

Create a New Freestyle Project:

Go to Jenkins main dashboard.
Click New Item, select Freestyle project, and enter a name for the project.
Configure Source Code Management:
Select Git and enter the Repository URL and credentials.

In your job configuration, go to the Build Environment section.
Check the Use secret text(s) or file(s) option.
Add a new binding for each of the username and password:
Type: Secret text.
Variable: DOCKER_USERNAME for the username, DOCKER_PASSWORD for the password.
Credentials: Select the credentials you added previously.
These variables (DOCKER_USERNAME and DOCKER_PASSWORD) will now be available as environment variables in your build steps.

Add Build Steps:

Invoke top-level Maven targets: Set Goals as clean package to build your Java application.

Build / Publish Docker Image:

Use a shell step to log in to Docker, build the Docker image, and push it to Docker Hub.


docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

docker build -t yourdockerhubuser/tomcatmavenapp:latest .

docker push yourdockerhubuser/tomcatmavenapp:latest .


# Deploy to Kubernetes:

Use another shell step to apply Kubernetes deployment manifests.

Go to your job configuration and scroll down to the Build Environment section.
Check the box Use secret text(s) or file(s).
Add a new Secret file binding:
Variable: Give it a name, like KUBECONFIG.
Credential: Select the kubeconfig credential you stored earlier.
This setup will expose the path to the kubeconfig file as an environment variable ($KUBECONFIG) within the job.

Add Execute Shell Build Step:
Use the $KUBECONFIG environment variable in your shell commands to reference the kubeconfig file:


kubectl --kubeconfig $KUBECONFIG apply -f deployment.yaml
kubectl --kubeconfig $KUBECONFIG apply -f service.yaml
Run the Job:
Click Build Now to start the Jenkins job.
Verify Deployment:
Check the deployment in Jenkins console output.
Use kubectl commands to verify the deployment on your EKS cluster:

kubectl get deployments
kubectl get services