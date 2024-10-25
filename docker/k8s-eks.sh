#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset

# Activate the virtual environment
. /data/venv/bin/activate

# Set the AWS region
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-eu-west-1}

# Get the cluster name from the first argument
export CLUSTER_NAME=$1

# Fetch the EKS cluster endpoint once
INTERNAL_ENDPOINT=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.endpoint" --output text)
DNSNAME=$(echo "$INTERNAL_ENDPOINT" | sed 's/https:\/\///')

# Replace private cluster endpoint in the rewrite filter
sed -i "s|CLUSTER_ENDPOINT|${INTERNAL_ENDPOINT}|g" /etc/privoxy/eks.filter

# Replace DNS name in the rewrite filter
sed -i "s|CLUSTER_DNS|${DNSNAME}|g" /etc/privoxy/eks.filter

# Replace cluster endpoint in the action file
sed -i "s|CLUSTER_ENDPOINT|${DNSNAME}|g" /etc/privoxy/eks.action

# Start Privoxy
privoxy --no-daemon /etc/privoxy/eksconfig