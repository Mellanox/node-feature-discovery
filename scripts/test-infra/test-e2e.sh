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


# Configure environment
export KIND_VERSION="v0.23.0"
export KIND_NODE_IMAGE="kindest/node:v1.30.2"
export CLUSTER_NAME="nfd-e2e"
export KUBECONFIG=`pwd`/kubeconfig
export IMAGE_REGISTRY="gcr.io/k8s-staging-nfd"
export E2E_TEST_FULL_IMAGE=true

# Install kind
go install sigs.k8s.io/kind@$KIND_VERSION

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

# Wait for the image to be built and published
i=1
while true; do
    if make poll-images; then
        break
    elif [ $i -ge 55 ]; then
        echo "ERROR: too many tries when polling for image"
        exit 1
    fi
    sleep 60

    i=$(( $i + 1 ))
done

# Configure environment and run tests
make e2e-test
