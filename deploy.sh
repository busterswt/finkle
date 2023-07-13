#!/bin/bash
# Copyright 2023, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in witing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###################
#### THE GOODS ####
###################

pushd /opt/bifrost/playbooks
source /opt/stack/bifrost/bin/activate
export BIFROST_INVENTORY_SOURCE="/opt/finkle/bifrost-inventory/baremetal-combined.yml"
ansible-playbook -vvvv \
  -i inventory/bifrost_inventory.py \
  deploy-dynamic.yaml
deactivate
popd
