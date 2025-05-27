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
this_dir=`dirname $0`

show_help() {
cat << EOF
    Usage: $this [-a APPLICATION_NAME]
    Aggregate the results from the specified application and plot the result.

    -a APPLICATION_NAME     run the pods with APPLICATION_NAME application.
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

for i in {1..10}
do
    kubectl logs -f demo-$app-$i-wo-discovery | grep real | cut -f2 | sed -e "s/m/*60+/" -e "s/s//" | bc >> temp.log
done
paste <(cat labels-without-discovery-$app.log) <(cat temp.log) > performance.log
rm -f temp.log labels-without-discovery-$app.log

for i in {1..10}
do
    kubectl logs -f demo-$app-$i-with-discovery | grep real | cut -f2 | sed -e "s/m/*60+/" -e "s/s//" | bc >> temp.log
done
paste <(cat labels-with-discovery-$app.log) <(cat temp.log) >> performance.log
rm -f temp.log labels-with-discovery-$app.log

minimum=$(awk 'min=="" || $2 < min {min=$2} END {print min}' performance.log)
awk -v min=$minimum '{print $1,((($2/min)*100))-100}' performance.log > performance-norm.log
"$this_dir/box-plot.R" performance.log performance-comparison-$app.pdf
"$this_dir/box-plot-norm.R" performance-norm.log performance-comparison-$app-norm.pdf

"$this_dir/clean-up.sh" -a $app
