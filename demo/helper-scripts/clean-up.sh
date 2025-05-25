#!/usr/bin/env bash
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


set -eo pipefail

this=`basename $0`

show_help() {
cat << EOF
    Usage: $this [-a APPLICATION_NAME]
    Clean-up pods with and without discovery enabled for the specified application.

    -a APPLICATION_NAME     clean-up the pods with APPLICATION_NAME application.
                            APPLICATION_NAME can be one of parsec or cloverleaf.
EOF
}

if [ $# -eq 0 ]
then
    show_help
    exit 1
fi

app="parsec"

OPTIND=1
options="ha:"
while getopts $options option
do
    case $option in
        a)
            if [ "$OPTARG" == "parsec" ] || [ "$OPTARG" == "cloverleaf" ]
            then
                app=$OPTARG
            else
                echo "Invalid application name."
                show_help
                exit 0
            fi
            ;;
        h)
            show_help
            exit 0
            ;;
        '?')
            show_help
            exit 1
            ;;
   esac
done

echo "Using application name = $app."
for i in {1..10}
do
    kubectl delete po demo-$app-$i-wo-discovery
done

for i in {1..10}
do
    kubectl delete po demo-$app-$i-with-discovery
done
