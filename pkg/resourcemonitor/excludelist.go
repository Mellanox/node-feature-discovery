// Copyright 2025 node-feature-discovery authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

package resourcemonitor

import (
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/util/sets"
	"k8s.io/klog/v2"
)

// ExcludeResourceList contains a list of resources to ignore during resources scan
type ExcludeResourceList struct {
	excludeList sets.Set[string]
}

// NewExcludeResourceList returns new ExcludeList with values with set.String types
func NewExcludeResourceList(resMap map[string][]string, nodeName string) ExcludeResourceList {
	excludeList := make(sets.Set[string])

	for k, v := range resMap {
		if k == nodeName || k == "*" {
			excludeList.Insert(v...)
		}
	}
	return ExcludeResourceList{
		excludeList: excludeList,
	}
}

func (rl *ExcludeResourceList) IsExcluded(resource corev1.ResourceName) bool {
	if rl.excludeList.Has(string(resource)) {
		klog.V(5).InfoS("resource excluded", "resourceName", resource)
		return true
	}
	return false
}
