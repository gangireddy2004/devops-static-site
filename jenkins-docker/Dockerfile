FROM jenkins/jenkins:lts

USER root

RUN apt-get update && apt-get install -y \
    docker.io \
    curl \
    unzip

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Terraform
RUN curl -LO https://releases.hashicorp.com/terraform/1.15.3/terraform_1.15.3_linux_amd64.zip && \
    unzip terraform_1.15.3_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.15.3_linux_amd64.zip

USER jenkins