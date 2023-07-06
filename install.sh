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

# DO NOT MODIFY #
export BIFROST_GIT_BRANCH=${BIFROST_GIT_BRANCH:-"stable/2023.1"}
export IPA_UPSTREAM_RELEASE=${IPA_UPSTREAM_RELEASE:-"stable-2023.1"}
export BIFROST_NETWORK_INTERFACE=${BIFROST_NETWORK_INTERFACE:-"ens4"}

###################
#### THE GOODS ####
###################

# Update host and install requirements
sudo apt update
sudo apt -y install python3-pip python3-venv

# Clone Bifrost to /opt/bifrost
echo "Cloning bifrost $BIFROST_GIT_BRANCH..."
git clone -b $BIFROST_GIT_BRANCH https://opendev.org/openstack/bifrost /opt/bifrost

# Run Ansible installer (provided by bifrost)
pushd /opt/bifrost
bash ./scripts/env-setup.sh
popd

# Run bifrost installer
pushd /opt/bifrost/playbooks
source /opt/stack/bifrost/bin/activate
ansible-playbook -vvvv -i inventory/target install.yaml -e git_branch=$BIFROST_GIT_BRANCH -e ipa_upstream_release=$IPA_UPSTREAM_RELEASE -e network_interface=$BIFROST_NETWORK_INTERFACE
popd


#mkdir /opt/rpc/
#python3 -m venv /opt/rpc/kicker
#/opt/rpc/kicker/bin/activate
#pip3 install ansible-core>=2.15.1
#ansible-galaxy collection install -r requirements.yml
