📁 Complete File Tree with Code
text
project-root/
├── index.html
├── style.css
├── script.js
├── Dockerfile
├── Jenkinsfile
├── kubernetes/
│   ├── deployment.yaml
│   └── service.yaml
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── monitoring/
    └── blackbox-addition.yaml
1. Static Website Files
index.html
html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOps Static Website</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>DevOps CI/CD Pipeline Project</h1>
        <p>HTML + CSS + JavaScript + Docker + Jenkins + Terraform + Kubernetes</p>
        <button onclick="showMessage()">Click Me</button>
        <p id="message"></p>
    </div>
    <script src="script.js"></script>
</body>
</html>
style.css
css
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    margin: 0;
    padding: 20px;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.container {
    background: white;
    border-radius: 20px;
    padding: 40px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.2);
    text-align: center;
    max-width: 600px;
    width: 90%;
    transition: transform 0.3s ease;
}

.container:hover {
    transform: translateY(-5px);
}

h1 {
    color: #333;
    margin-bottom: 10px;
}

p {
    color: #666;
    font-size: 1.1rem;
    margin: 20px 0;
}

button {
    background: #007acc;
    color: white;
    border: none;
    padding: 12px 30px;
    font-size: 1rem;
    border-radius: 30px;
    cursor: pointer;
    transition: background 0.3s, transform 0.1s;
}

button:hover {
    background: #005fa3;
}

button:active {
    transform: scale(0.98);
}

#message {
    margin-top: 20px;
    font-weight: bold;
    color: #28a745;
}
script.js
javascript
function showMessage() {
    const msg = document.getElementById("message");
    msg.innerText = "✅ Pipeline deployment successful! 🚀";
    msg.style.opacity = "0";
    msg.style.transition = "opacity 0.5s";
    setTimeout(() => { msg.style.opacity = "1"; }, 10);
    setTimeout(() => {
        msg.style.opacity = "0";
        setTimeout(() => { msg.innerText = ""; }, 500);
    }, 3000);
}
2. Docker Configuration
Dockerfile
dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
3. CI/CD Pipeline (Jenkins)
Jenkinsfile
groovy
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'gangireddy16/devops-static-site'
        DOCKER_TAG = 'latest'
        K8S_DEPLOYMENT = 'kubernetes/deployment.yaml'
        K8S_SERVICE = 'kubernetes/service.yaml'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/your-username/your-repo.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig-secret']) {
                    sh "kubectl apply -f ${K8S_DEPLOYMENT}"
                    sh "kubectl apply -f ${K8S_SERVICE}"
                    sh "kubectl rollout status deployment/static-site"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline succeeded! Website updated."
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
4. Kubernetes Manifests
kubernetes/deployment.yaml
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-site
spec:
  replicas: 2
  selector:
    matchLabels:
      app: static-site
  template:
    metadata:
      labels:
        app: static-site
    spec:
      containers:
      - name: static-site
        image: gangireddy16/devops-static-site:latest
        ports:
        - containerPort: 80
        imagePullPolicy: Always
kubernetes/service.yaml
yaml
apiVersion: v1
kind: Service
metadata:
  name: static-site-service
spec:
  selector:
    app: static-site
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
5. Terraform (Local Docker – optional)
terraform/provider.tf
hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
terraform/main.tf
hcl
resource "docker_image" "static_site" {
  name = "gangireddy16/devops-static-site:latest"
}

resource "docker_container" "web" {
  name  = "terraform-static-site"
  image = docker_image.static_site.image_id

  ports {
    internal = 80
    external = var.host_port
  }
}
terraform/variables.tf
hcl
variable "host_port" {
  description = "Port on the host machine to map to container port 80"
  type        = number
  default     = 8086
}
terraform/outputs.tf
hcl
output "website_url" {
  value = "http://localhost:${docker_container.web.ports[0].external}"
}

output "container_id" {
  value = docker_container.web.id
}
6. Monitoring – Prometheus Blackbox Exporter
monitoring/blackbox-addition.yaml
yaml
prometheus:
  prometheusSpec:
    additionalScrapeConfigs:
      - job_name: 'static-website-blackbox'
        metrics_path: /probe
        params:
          module: [http_2xx]
        static_configs:
          - targets:
              - http://static-site-service.default.svc.cluster.local:80
        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: blackbox-prometheus-blackbox-exporter:9115
Note: The service name blackbox-prometheus-blackbox-exporter assumes the Prometheus Blackbox Exporter is installed via the prometheus-community/kube-prometheus-stack Helm chart. If your exporter has a different service name, adjust accordingly.

🛠️ Step‑by‑Step Development Guide
1️⃣ Prerequisites (Install on your machine)
Tool	Why	Installation link
Docker	Build & run containers	docker.com
Minikube	Local Kubernetes cluster	minikube.sigs.k8s.io
kubectl	Manage Kubernetes	kubernetes.io
Terraform	Infrastructure as Code (optional)	terraform.io
Jenkins	CI/CD server	jenkins.io
Git	Version control	git-scm.com
Helm	Install Prometheus stack	helm.sh
2️⃣ Create the Static Website Locally
bash
mkdir devops-static-site && cd devops-static-site
# Create the three files: index.html, style.css, script.js (copy from above)
Test with a simple HTTP server:

bash
python3 -m http.server 8000
# Open http://localhost:8000
3️⃣ Dockerise the Website
Create Dockerfile (content above). Build & run:

bash
docker build -t my-static-site .
docker run -d -p 8080:80 my-static-site
curl http://localhost:8080   # Should return HTML
Push to Docker Hub (replace gangireddy16 with your username):

bash
docker tag my-static-site gangireddy16/devops-static-site:latest
docker login
docker push gangireddy16/devops-static-site:latest
4️⃣ Set up Kubernetes (Minikube)
bash
minikube start
kubectl create namespace devops
Apply the manifests:

bash
kubectl apply -f kubernetes/deployment.yaml -n devops
kubectl apply -f kubernetes/service.yaml -n devops
Check everything:

bash
kubectl get pods -n devops
kubectl get svc -n devops
Access the website:

bash
minikube service static-site-service -n devops --url
# Or use port-forward: kubectl port-forward svc/static-site-service 8080:80 -n devops
5️⃣ Install Prometheus & Blackbox Exporter
Add the Prometheus community repo and install the kube-prometheus-stack (includes Blackbox Exporter):

bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
After installation, the Blackbox Exporter service will be named something like prometheus-kube-prometheus-blackbox-exporter. Verify:

bash
kubectl get svc -n monitoring | grep blackbox
Edit monitoring/blackbox-addition.yaml and replace blackbox-prometheus-blackbox-exporter with the actual service name (e.g., prometheus-kube-prometheus-blackbox-exporter).

Apply the additional scrape configuration:

bash
kubectl create secret generic additional-scrape-configs --from-file=blackbox-addition.yaml -n monitoring
kubectl patch prometheus prometheus-kube-prometheus-prometheus -n monitoring --type merge --patch '
spec:
  additionalScrapeConfigs:
    name: additional-scrape-configs
    key: blackbox-addition.yaml
'
Restart Prometheus pods:

bash
kubectl rollout restart statefulset prometheus-prometheus-kube-prometheus-prometheus -n monitoring
Check targets in Prometheus UI:

bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
# Open http://localhost:9090/targets
6️⃣ Jenkins Pipeline Setup
Install Jenkins (use Docker or local package).

Install plugins: Docker Pipeline, Kubernetes CLI, GitHub Integration.

Add credentials in Jenkins:

docker-hub-credentials (username/password or token)

kubeconfig-secret (upload your kubeconfig file from ~/.kube/config)

github-credentials (personal access token)

Create a new Pipeline job, choose “Pipeline script from SCM”, point to your GitHub repo (branch main), and set Script Path to Jenkinsfile.

In GitHub, add a webhook: http://<jenkins-ip>:8080/github-webhook/.

Push a change (e.g., edit index.html) – Jenkins should build, push, and deploy automatically.

7️⃣ Terraform (Local Docker – Optional)
If you want to run the website locally without Kubernetes:

bash
cd terraform
terraform init
terraform plan
terraform apply
# Access at http://localhost:8086
terraform destroy   # Clean up
✅ Verification Commands
What to check	Command
Kubernetes pods	kubectl get pods -n devops
Service endpoint	minikube service static-site-service -n devops --url
Prometheus targets	kubectl port-forward svc/prometheus-prometheus -n monitoring 9090 → Targets
Probe success	Prometheus query: probe_success{job="static-website-blackbox"}
Jenkins build logs	Jenkins UI → job → Console Output
🧪 Prometheus Queries to Monitor the Site
promql
# Success rate (1 = up, 0 = down)
probe_success{job="static-website-blackbox"}

# HTTP request duration (seconds)
probe_http_duration_seconds{job="static-website-blackbox", phase="connect"}

# Uptime percentage over last 5 minutes
avg_over_time(probe_success{job="static-website-blackbox"}[5m]) * 100
🐞 Common Errors & Fixes
Error	Solution
ImagePullBackOff	Ensure image name is correct and public. Use imagePullPolicy: Always.
Blackbox target down	Check if service DNS resolves: kubectl run -it --rm debug --image=busybox -- nslookup static-site-service
Jenkins cannot connect to Docker	Add jenkins user to docker group: sudo usermod -aG docker jenkins and restart.
Terraform fails with permission denied for Docker socket	Run sudo chmod 666 /var/run/docker.sock (not recommended for production) or add your user to docker group.
Prometheus doesn’t see new scrape config	Check secret name and patch. Look at Prometheus pod logs: kubectl logs prometheus-0 -n monitoring
🎯 What You Have Built
✅ A responsive static website with HTML/CSS/JS

✅ Docker image published to Docker Hub

✅ Kubernetes deployment with 2 replicas + NodePort service

✅ Fully automated CI/CD pipeline with Jenkins + GitHub webhook

✅ Monitoring with Prometheus Blackbox exporter (website uptime & latency)

✅ (Optional) Terraform‑managed local Docker container

👤 Author
Gangireddy – DevOps Engineer
GitHub

