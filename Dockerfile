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

ARG BUILDER_IMAGE
ARG BASE_IMAGE_FULL
ARG BASE_IMAGE_MINIMAL

# Build node feature discovery
FROM ${BUILDER_IMAGE:-golang} AS builder

# Get (cache) deps in a separate layer
COPY go.mod go.sum /go/node-feature-discovery/
COPY api/nfd/go.mod api/nfd/go.sum /go/node-feature-discovery/api/nfd/

WORKDIR /go/node-feature-discovery

RUN --mount=type=cache,target=/go/pkg/mod/ \
    go mod download

# Do actual build
ARG VERSION
ARG HOSTMOUNT_PREFIX

RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=src=.,target=. \
    make install VERSION=$VERSION HOSTMOUNT_PREFIX=$HOSTMOUNT_PREFIX

# Create full variant of the production image
FROM ${BASE_IMAGE_FULL:-debian:stable-slim} AS full

# Run as unprivileged user
USER 65534:65534

# Use more verbose logging of gRPC
ENV GRPC_GO_LOG_SEVERITY_LEVEL="INFO"

COPY deployment/components/worker-config/nfd-worker.conf.example /etc/kubernetes/node-feature-discovery/nfd-worker.conf
COPY --from=builder /go/bin/* /usr/bin/

# Create minimal variant of the production image
FROM ${BASE_IMAGE_MINIMAL:-scratch} AS minimal

# Run as unprivileged user
USER 65534:65534

# Use more verbose logging of gRPC
ENV GRPC_GO_LOG_SEVERITY_LEVEL="INFO"

COPY deployment/components/worker-config/nfd-worker.conf.example /etc/kubernetes/node-feature-discovery/nfd-worker.conf
COPY --from=builder /go/bin/* /usr/bin/
