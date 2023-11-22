#!/bin/bash

# Log into AWS account with aws configure or aws sso, then run this script.
# Make sure script and yaml file are in the same directory.

EKS_CLUSTER=$1
REGION=$2
PROFILE=$3

aws eks update-kubeconfig --name "${EKS_CLUSTER}" --region "${REGION}" --profile "${PROFILE}" 

kubectl apply -f nginx.yaml
