#!/bin/bash -e
# Copyright 2025 node-feature-discovery authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

set -o pipefail

# Configure environment
export KIND_VERSION="v0.23.0"
export HELM_VERSION="v3.17.3"
export KIND_NODE_IMAGE="kindest/node:v1.30.2"
export CLUSTER_NAME="nfd-e2e"
export KUBECONFIG="/tmp/kubeconfig_$CLUSTER_NAME"
export IMAGE_REPO="registry.local/node-feature-discovery"
export IMAGE_TAG_NAME=$(git describe --tags --dirty --always --match "v*")

# Install kind
go install sigs.k8s.io/kind@$KIND_VERSION

# Install helm (required for helm e2e tests)
curl -sfL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -s -- --version $HELM_VERSION

# create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --kubeconfig $KUBECONFIG --image $KIND_NODE_IMAGE --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: $CLUSTER_NAME
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

# build the local image
make image IMAGE_REPO=$IMAGE_REPO IMAGE_TAG_NAME=$IMAGE_TAG_NAME

# push the image to the local registry
kind load docker-image $IMAGE_REPO:$IMAGE_TAG_NAME --name $CLUSTER_NAME

# run the tests
make e2e-test IMAGE_REPO=$IMAGE_REPO IMAGE_TAG_NAME=$IMAGE_TAG_NAME E2E_PULL_IF_NOT_PRESENT=true
