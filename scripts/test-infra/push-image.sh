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


# Override VERSION if _GIT_TAG is specified. Strip 10 first characters
# ('vYYYYMMDD-') from _GIT_TAG in order to get a reproducible version and
# container image tag
VERSION_OVERRIDE=${_GIT_TAG+VERSION=${_GIT_TAG:10}}

# Authenticate in order to be able to push images
gcloud auth configure-docker

# Build and push images
IMAGE_ALL_PLATFORMS=linux/amd64,linux/arm64 make push-all $VERSION_OVERRIDE

go install helm.sh/helm/v3/cmd/helm@v3.17.3

make helm-push $VERSION_OVERRIDE
