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

all
# Exclude MD022 - Headers should be surrounded by blank lines. The kramdown
# "class magic" (like {: .no_toc}) needs to be directly below the heading line.
exclude_rule 'MD022'
# Exclude MD041 - First line in file should be a top level header
exclude_rule 'MD041'
rule 'MD013', :tables => false
rule 'MD007', :indent => 2
rule 'MD013', :ignore_code_blocks => true
rule 'MD024', :allow_different_nesting => true
# MD056 - Inconsistent number of columns in table
# docs/deployment/helm.md:98
exclude_rule 'MD056'
