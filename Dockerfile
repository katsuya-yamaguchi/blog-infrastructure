FROM ubuntu:latest

ARG REGION
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

WORKDIR /var/tmp
RUN apt-get update && \
    apt-get install -y wget \
                       unzip \
                       less \
                       jq \
                       ssh &&\
    wget "https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip"  && \
    unzip terraform_0.12.24_linux_amd64.zip && \
    wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"  && \
    unzip awscli-exe-linux-x86_64.zip && \
    ./aws/install  && \
    rm -f terraform_0.12.24_linux_amd64.zip \
          awscli-exe-linux-x86_64.zip &&\
    mv terraform /usr/local/bin/

COPY config /root/.aws/config
COPY credentials /root/.aws/credentials

RUN sed -i "s/REGION/${REGION}/g" /root/.aws/config && \
    sed -i "s/AWS_ACCESS_KEY_ID/${AWS_ACCESS_KEY_ID}/g" /root/.aws/credentials && \
    sed -i "s/AWS_SECRET_ACCESS_KEY/${AWS_SECRET_ACCESS_KEY}/g" /root/.aws/credentials
