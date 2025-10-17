#!/bin/bash

# PC USERNAME AND PASSWORD

export PC_ENDPOINT=https://<pc_ip>:9440/
export NUTANIX_USER=
export NUTANIX_PASSWORD=

# PE CLUSTER NAME AND PROJECT

export PE_CLUSTER=

export PROJECT=
export WORKER_CAT=
export CP_CAT=


# IMAGE REGISTRY

export REGISTRY_PASSWORD=
export REGISTRY_USERNAME=
export REGISTRY_URL=
export CA_CERT=

# STROAGE CONTATNER NAME

export STROAGE_CONTATNER=

# MANAGEMENT CLUSTER NAME, IP AND SUBNET

export CLUSTER_NAME=
export CP_ENDPOINT_IP=
export SUBNET=
export SSH_KEY_FILE="/root/.ssh/id_rsa.pub"
export SSH_USER=konvoy

# LB RANGE, POD AND SVC NETWORK

export LB_RANGE=
export POD_NET=
export SVC_NET=

# IMAGE FOR MASTER AND WORKER NODE AND CPV, MEMORY, DISK REPLICAS

export NKP_IMAGE=
export WORKER_DISK_SIZE=
export WORKER_MEM=
export WORKER_VCPU=
export WORKER_CP_VCPU=
export WORKER_REPLICAS=
export CTR_DISK_SIZE=
export CTR_MEM=
export CTR_VCPU=
export CTR_CP_VCPU=
export CTR_REPLICAS=

export OUTPUT=yaml
export CL_HOSTNAME=

nkp create cluster nutanix \
--endpoint ${PC_ENDPOINT} \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-ip ${CP_ENDPOINT_IP} \
--control-plane-prism-element-cluster ${PE_CLUSTER} \
--control-plane-subnets ${SUBNET} \
--control-plane-vm-image ${NKP_IMAGE} \
--control-plane-memory ${CTR_MEM} \
--control-plane-disk-size ${CTR_DISK_SIZE} \
--control-plane-vcpus ${CTR_VCPU} \
--control-plane-replicas=3 \
--control-plane-cores-per-vcpu ${CTR_CP_VCPU} \
--control-plane-pc-project ${PROJECT} \
--control-plane-pc-categories ${CP_CAT} \
--worker-prism-element-cluster=${PE_CLUSTER} \
--worker-subnets ${SUBNET} \
--worker-vm-image ${NKP_IMAGE} \
--worker-disk-size ${WORKER_DISK_SIZE} \
--worker-memory ${WORKER_MEM} \
--worker-cores-per-vcpu ${WORKER_CP_VCPU} \
--worker-replicas=4 \
--worker-vcpus ${WORKER_VCPU} \
--worker-pc-project ${PROJECT} \
--worker-pc-categories ${WORKER_CAT} \
--csi-storage-container ${STROAGE_CONTATNER} \
--kubernetes-service-load-balancer-ip-range ${LB_RANGE} \
--csi-hypervisor-attached-volumes=true \
--ssh-public-key-file ${SSH_KEY_FILE} \
--ssh-username ${SSH_USER} \
--registry-mirror-cacert ${CA_CERT} \
--registry-mirror-password ${REGISTRY_PASSWORD} \
--registry-mirror-url ${REGISTRY_URL} \
--registry-mirror-username ${REGISTRY_USERNAME} \
--kubernetes-pod-network-cidr ${POD_NET} \
--kubernetes-service-cidr ${SVC_NET} \
--verbose 4 \
--airgapped \
--insecure=true
--output=yaml \
--output-directory=nkp-mgmt-manifests
