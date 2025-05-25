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


# Pre-create output directory with all write access. The Jekyll docker image is
# stupid enough to do all sorts of uid/gid/chown magic making build fail for
# root user. In prow we run as root because of DIND.
_outdir="docs/_site"
mkdir -p "$_outdir"
chmod a+rwx "$_outdir"

# Build docs
make site-build
