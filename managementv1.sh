#!/bin/bash

# Ask user for all necessary values

read -p "Enter PC IP (without https:// and :9440): " pc_ip
PC_ENDPOINT="https://${pc_ip}:9440/"

read -p "Enter Nutanix Username: " NUTANIX_USER
read -s -p "Enter Nutanix Password: " NUTANIX_PASSWORD
echo

read -p "Enter PE Cluster Name: " PE_CLUSTER
read -p "Enter Project Name: " PROJECT
read -p "Enter Worker Categories: " WORKER_CAT
read -p "Enter Control Plane Categories: " CP_CAT

read -p "Enter Registry Username: " REGISTRY_USERNAME
read -s -p "Enter Registry Password: " REGISTRY_PASSWORD
echo
read -p "Enter Registry URL: " REGISTRY_URL
read -p "Enter Path to CA Certificate File: " CA_CERT

read -p "Enter Storage Container Name: " STROAGE_CONTATNER

read -p "Enter Cluster Name: " CLUSTER_NAME
read -p "Enter Control Plane Endpoint IP: " CP_ENDPOINT_IP
read -p "Enter Subnet: " SUBNET
read -p "Enter SSH Public Key File Path [/root/.ssh/id_rsa.pub]: " SSH_KEY_FILE
SSH_KEY_FILE=${SSH_KEY_FILE:-/root/.ssh/id_rsa.pub}
read -p "Enter SSH Username [konvoy]: " SSH_USER
SSH_USER=${SSH_USER:-konvoy}

read -p "Enter Load Balancer IP Range (CIDR): " LB_RANGE
read -p "Enter Pod Network CIDR: " POD_NET
read -p "Enter Service Network CIDR: " SVC_NET

read -p "Enter NKP Image: " NKP_IMAGE

read -p "Enter Worker Disk Size: " WORKER_DISK_SIZE
read -p "Enter Worker Memory: " WORKER_MEM
read -p "Enter Worker VCPUs: " WORKER_VCPU
read -p "Enter Worker CPU cores per VCPU: " WORKER_CP_VCPU
read -p "Enter Number of Worker Replicas: " WORKER_REPLICAS

read -p "Enter Control Plane Disk Size: " CTR_DISK_SIZE
read -p "Enter Control Plane Memory: " CTR_MEM
read -p "Enter Control Plane VCPUs: " CTR_VCPU
read -p "Enter Control Plane CPU cores per VCPU: " CTR_CP_VCPU
read -p "Enter Number of Control Plane Replicas [3]: " CTR_REPLICAS
CTR_REPLICAS=${CTR_REPLICAS:-3}

read -p "Enter Output Format [yaml]: " OUTPUT
OUTPUT=${OUTPUT:-yaml}

read -p "Enter Cluster Hostname (optional): " CL_HOSTNAME


# Run the nkp create cluster command using the collected variables

nkp create cluster nutanix \
  --endpoint "${PC_ENDPOINT}" \
  --cluster-name "${CLUSTER_NAME}" \
  --control-plane-endpoint-ip "${CP_ENDPOINT_IP}" \
  --control-plane-prism-element-cluster "${PE_CLUSTER}" \
  --control-plane-subnets "${SUBNET}" \
  --control-plane-vm-image "${NKP_IMAGE}" \
  --control-plane-memory "${CTR_MEM}" \
  --control-plane-disk-size "${CTR_DISK_SIZE}" \
  --control-plane-vcpus "${CTR_VCPU}" \
  --control-plane-replicas="${CTR_REPLICAS}" \
  --control-plane-cores-per-vcpu "${CTR_CP_VCPU}" \
  --control-plane-pc-project "${PROJECT}" \
  --control-plane-pc-categories "${CP_CAT}" \
  --worker-prism-element-cluster="${PE_CLUSTER}" \
  --worker-subnets "${SUBNET}" \
  --worker-vm-image "${NKP_IMAGE}" \
  --worker-disk-size "${WORKER_DISK_SIZE}" \
  --worker-memory "${WORKER_MEM}" \
  --worker-cores-per-vcpu "${WORKER_CP_VCPU}" \
  --worker-replicas="${WORKER_REPLICAS}" \
  --worker-vcpus "${WORKER_VCPU}" \
  --worker-pc-project "${PROJECT}" \
  --worker-pc-categories "${WORKER_CAT}" \
  --csi-storage-container "${STROAGE_CONTATNER}" \
  --kubernetes-service-load-balancer-ip-range "${LB_RANGE}" \
  --csi-hypervisor-attached-volumes=true \
  --ssh-public-key-file "${SSH_KEY_FILE}" \
  --ssh-username "${SSH_USER}" \
  --registry-mirror-cacert "${CA_CERT}" \
  --registry-mirror-password "${REGISTRY_PASSWORD}" \
  --registry-mirror-url "${REGISTRY_URL}" \
  --registry-mirror-username "${REGISTRY_USERNAME}" \
  --kubernetes-pod-network-cidr "${POD_NET}" \
  --kubernetes-service-cidr "${SVC_NET}" \
  --verbose 4 \
  --airgapped \
  --insecure=true \
  --output="${OUTPUT}" \
  --output-directory=nkp-mgmt-manifests
