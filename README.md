# Valavaxyconsultancyapi

# Follow these steps to setup jenkins, kubernetes cluster in eks, build deploy java app and monitoring using prometheus and grafana
when creating the jenkins master, make sure you use the jenkins-user-data.sh script find this file under scripts folder . After the jenkins instance is up and running, access jenkins from your browser using instance "public-ip:8080" also run the folowing commands on ther terminal to confirm master node is fully configured to run kube and eks commands;

```bash
aws --version

kubectl version --client

eksctl version

eksctl version
```

# Step 1  Creating and Attaching an IAM Role to the Jenkins Instance
You will ne to create and attach an IAM role to the jenkins instance for EKS management:

Create the IAM Role:

Navigate to the IAM service in the AWS Management Console.
Create a new role and select AWS service as the type of trusted entity, choosing EC2 as the service that will use this role.

Attach policies that grant permissions needed to manage EKS. 
just give admin access 
Attach the Role to the EC2 Instance:
Go to the EC2 dashboard in the AWS Management Console.
Find the EC2 instance that you use as your management node "jenkins".
Select the instance, then click on Actions > Security > Modify IAM role.
Select the IAM role you created from the drop-down menu and apply the changes.
Configuring the Instance
Once the IAM role is attached:

Any AWS CLI or SDK tool running on the instance will automatically use the credentials provided by the IAM role.
You won’t need to manually configure AWS credentials on the instance, enhancing security by not storing sensitive information on the instance.

# Now create the cluster with the following command

```bash
eksctl create cluster --name ezlearn-cluster --region us-east-1 --node-type t3.medium --nodes 2
```


First, ensure your EKS cluster is ready.







# Step 2: Configure Jenkins


Install Necessary Plugins:

Navigate to Manage Jenkins > Manage Plugins > Available and install these plugins:

Maven Integration plugin – for building Java applications.
Docker Pipeline – for Docker operations.
Kubernetes CLI Plugin – to interact with your Kubernetes cluster.

Configure Jenkins Tools:
Go to Manage Jenkins > Global Tool Configuration.
Select JDK and click to install automatically

Set up Maven, give it a name maven. do not select automatic install, just give the path of maven
maven path will be /opt/maven

Apply and save

# Step 3: Add Required Credentials in Jenkins
Add Credentials:
Go to Manage Jenkins > Manage Credentials > Jenkins > Global credentials (unrestricted) > Add Credentials.
Add credentials for Docker Hub, and a kubeconfig for Kubernetes:

Docker Hub credentials select Username and password, then input you actuall docker account user-name and password
give it any ID of your choice

Add credentials for kubernetes

Go to jenkins terminal and run the command 

```bash
sudo cat .kube/config
```
copy the content of the file and save it in your local computer with name config

Add Credentials:
Go to Manage Jenkins > Manage Credentials > Jenkins > Global credentials (unrestricted) > Add Credentials.
Add credentials for Kubernetes:

Select secret file, click browse and upload the config file you saved in your local pc


Assign any ID name of your choice that you can refer to in your Jenkins jobs.

# Step 4: Create a Jenkins Job

Create a New Freestyle Project:

Go to Jenkins main dashboard.
Click New Item, select Freestyle project, and enter a name for the project.
Configure Source Code Management:
Select Git and enter the Repository URL 

In your job configuration, go to the Build Environment section.
Check the Use secret text(s) or file(s) option.
Add a new binding for each of the username and password by selecting username and password (separated):
under User Variable type DOCKER_USERNAME for the username, under Password Variable type DOCKER_PASSWORD for the password.
Credentials: Select the credentials you added previously.
These variables (DOCKER_USERNAME and DOCKER_PASSWORD) will now be available as environment variables in your build steps.

ADD config for kubeconfig
Click Add annd select secret file
Variable: Give it a name, like KUBECONFIG.
Credential: Select the kubeconfig credential you stored earlier.
This setup will expose the path to the kubeconfig file as an environment variable ($KUBECONFIG) within the job.

# Build Steps
Click on Add Build Steps and select Invoke top-level Maven targets:
 Set Goals as "clean install" to build your Java application.

Build / Publish Docker Image:
Click on Add Build Steps and select execute shell
Use a shell step to log in to Docker, build the Docker image, and push it to Docker Hub.
Copy the commands below and paste

```bash
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

docker build -t yourdockerhubuser/tomcatmavenapp:latest .

docker push yourdockerhubuser/tomcatmavenapp:latest 
```

# Deploy the entire pipeline to Kubernetes:

Use another shell step to apply Kubernetes deployment manifests.



```bash
# Apply Prometheus configurations
kubectl --kubeconfig $CONFIG apply -f prometheus-serviceaccount.yaml
kubectl --kubeconfig $CONFIG apply -f prometheus-clusterrole.yaml
kubectl --kubeconfig $CONFIG apply -f prometheus-clusterrolebinding.yaml
kubectl --kubeconfig $CONFIG apply -f prometheus-configmap.yaml
kubectl --kubeconfig $CONFIG apply -f prometheus-deployment.yaml
kubectl --kubeconfig $CONFIG apply -f prometheus-service.yaml

kubectl --kubeconfig $CONFIG apply -f node-exporter-daemonset.yaml

kubectl --kubeconfig $CONFIG apply -f grafana-deployment.yaml
kubectl --kubeconfig $CONFIG apply -f grafana-service.yaml

# Apply application deployment and service
kubectl --kubeconfig $CONFIG apply -f deployment.yml
kubectl --kubeconfig $CONFIG apply -f service.yml

kubectl --kubeconfig $CONFIG rollout restart deployment prometheus -n default
kubectl --kubeconfig $CONFIG rollout restart deployment grafana -n default
kubectl --kubeconfig $CONFIG rollout restart deployment tomcatmavenapp-deployment -n default

# Check status of deployments and services
kubectl --kubeconfig $CONFIG get deployments -n default
kubectl --kubeconfig $CONFIG get services -n default
```

# Run the Job:
Click Build Now to start the Jenkins job.
Verify Deployment:
Check the deployment in Jenkins console output.
Use kubectl commands to verify the deployment on your EKS cluster:

```bash
kubectl get deployments
kubectl get services
