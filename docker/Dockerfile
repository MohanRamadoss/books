FROM alpine:latest

# Update the package list and install dependencies: AWS CLI, Privoxy, jq, Python3, pip
RUN apk update && apk add --no-cache \
    curl \
    privoxy \
    jq \
    python3 \
    py3-pip \
    openssl \
    && python3 -m venv /data/venv \
    && /data/venv/bin/pip install --no-cache --upgrade pip setuptools \
    && /data/venv/bin/pip install awscli \
    && chown -R privoxy /etc/privoxy

# Add Privoxy configuration files
ADD eksconfig /etc/privoxy/
ADD eks.action /etc/privoxy/
ADD eks.filter /etc/privoxy/

# Set permissions for Privoxy config
RUN chown -R privoxy /etc/privoxy

# Add the script that sets up the EKS and Privoxy
ADD k8s-eks.sh /

# Make the script executable
RUN chmod +x /k8s-eks.sh

# Expose port 8118 for Privoxy
EXPOSE 8118/tcp

# Set environment variables for AWS
ENV AWS_STS_REGIONAL_ENDPOINTS=regional
ENV AWS_DEFAULT_REGION=eu-west-1
ENV AWS_REGION=eu-west-1
#ENV AWS_ROLE_ARN=arn:aws:iam::234343523:role/irsa-eks-cluster
#ENV AWS_WEB_IDENTITY_TOKEN_FILE=/var/run/secrets/eks.amazonaws.com/serviceaccount/token

# Run the EKS setup script on container start
ENTRYPOINT ["./k8s-eks.sh"]