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


# Tool versions
HELM_VERSION="v3.17.3"
ORAS_VERSION="v1.2.3"

# Override VERSION if _GIT_TAG is specified. Strip 10 first characters
# ('vYYYYMMDD-') from _GIT_TAG in order to get a reproducible version and
# container image tag
if [[ $_PULL_BASE_REF =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    MAKE_VARS="VERSION=${_PULL_BASE_REF}"
else
    MAKE_VARS="VERSION=${_GIT_TAG:10} IMAGE_EXTRA_TAG_NAMES=${_PULL_BASE_REF} CHART_EXTRA_VERSIONS=0.0.0-${_PULL_BASE_REF}"
fi

# Authenticate in order to be able to push images
gcloud auth configure-docker

# Build and push images
IMAGE_ALL_PLATFORMS=linux/amd64,linux/arm64,linux/s390x,linux/ppc64le make push-all $MAKE_VARS

go install helm.sh/helm/v3/cmd/helm@$HELM_VERSION
go install oras.land/oras/cmd/oras@$ORAS_VERSION

make helm-push $VERSION_OVERRIDE $MAKE_VARS
