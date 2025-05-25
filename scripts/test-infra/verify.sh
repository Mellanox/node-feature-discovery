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


this_dir=`dirname $0`

# Install deps
gobinpath="$(go env GOPATH)/bin"
curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b "$gobinpath" v1.64.5
export PATH=$PATH:$(go env GOPATH)/bin

curl -sfL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -s -- --version v3.15.3

kubectl="$gobinpath/kubectl"
curl -L https://dl.k8s.io/release/v1.22.1/bin/linux/amd64/kubectl -o "$kubectl"
chmod 755 "$kubectl"

curl https://keybase.io/codecovsecurity/pgp_keys.asc | gpg --no-default-keyring --keyring trustedkeys.gpg --import
curl -Os https://uploader.codecov.io/latest/linux/codecov
chmod +x codecov

go install sigs.k8s.io/logtools/logcheck@v0.8.1

# Run verify steps
echo "Checking gofmt"
make gofmt-verify

echo "Running golangci-lint"
make ci-lint

echo "Running Helm lint"
make helm-lint

echo "Running logcheck"
logcheck -config "${this_dir}/logcheck.conf" ./cmd/... ./pkg/...  ./source/...

echo "Running unit tests"
make test

# Upload coverage report
./codecov -t "${CODECOV_TOKEN}" \
          -C "${PULL_PULL_SHA}" \
          -r "${REPO_OWNER}/${REPO_NAME}" \
          -P "${PULL_NUMBER}" \
          -b "${BUILD_ID}" \
          -B "${PULL_BASE_REF}" \
          -N "${PULL_BASE_SHA}"

# Check that repo is clean
if ! git diff --quiet; then
    echo "Repository is dirty!"
    exit 1
fi

# Check that templates are up-to-date
make templates
if ! git diff --quiet; then
    echo "Deployment templates are not up-to-date. Run 'make templates' to update"
    exit 1
fi

# Check that the kustomize overlays are buildable
for d in `ls deployment/overlays/* -d`; do
    if [ "`basename $d`" = "samples" ]; then
        continue
    fi

    echo "Verifying $d"
    kubectl kustomize $d > /dev/null
done
