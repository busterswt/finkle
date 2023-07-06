Finkle
######
:date: 2023-07-06
:tags: kickstart, rackspace, openstack, ansible, openstack-ansible

About this repository
---------------------

Bifrost is Ironic! Ironic is Bifrost!
 
Finkle is a kickstart-type project based on Bifrost, which can be considered
'Ironic Lite'.

Requirements
------------

- 1x Utility Node or Virtual Machine (4 vCPUs, 16 GB RAM, 60 GB Disk)
- Management Network (to access the Utility node/vm)
- PXE Network (to allow Bifrost to provision baremetal nodes)
- IPMI Network (to allow Bifrost to tickle baremetal nodes)

Installation
------------

Download this repository to a utility node or virtual machine that has access
to both the IPMI and PXE networks of a given cloud

.. code-block:: bash

    git clone https://github.com/busterswt/finkle /opt/finkle

Prerequisites
-------------

- Ubuntu 22.04 LTS (Jammy)
- 2x Network interfaces (Management & PXE)

- The management interface allows access to/from the Bifrost host, including to IPMI/OOB
- The PXE interface allows the Bifrost host to respond to DHCP/TFTP requests from baremetal nodes

.. code-block:: bash

    ubuntu@bifrost-demo01:/opt/finkle$ ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
       inet6 ::1/128 scope host
           valid_lft forever preferred_lft forever
    2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether fa:16:3e:b3:e3:4e brd ff:ff:ff:ff:ff:ff
        altname enp0s3
        inet 50.57.217.157/28 metric 100 brd 50.57.217.159 scope global dynamic ens3
           valid_lft 49722sec preferred_lft 49722sec
        inet6 fe80::f816:3eff:feb3:e34e/64 scope link
           valid_lft forever preferred_lft forever
    3: ens4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether fa:16:3e:25:8a:91 brd ff:ff:ff:ff:ff:ff
        altname enp0s4
        inet 192.168.55.232/24 brd 192.168.55.255 scope global ens4
           valid_lft forever preferred_lft forever
        inet6 fe80::f816:3eff:fe25:8a91/64 scope link
           valid_lft forever preferred_lft forever

Installation
------------

From within the finkle directory, execute the following to install required
components as well as Bifrost:

.. code-block:: bash

    Ubuntu 22.04 LTS
    ----------------
    cd /opt/finkle; bash install.sh

Overrides
---------

Overrides can be set in `overrides.yml`, which will be read in by Ansible to
override default values. Other overrides can be set using environment variables
prior to executing the build, but this will be deprecated in most cases.

``install.sh`` Options
====================

Required
^^^^^^^^

None

Optional
^^^^^^^^

The variables here are optional, as there are defaults in place. Change them according to
your deployment preference:

Set the Bifrost branch
  ``export BIFROST_GIT_BRANCH=${BIFROST_GIT_BRANCH:-"stable/2023.1"}``

Set the Ironic Python Agent branch
  ``export IPA_UPSTREAM_RELEASE=${IPA_UPSTREAM_RELEASE:-"stable-2023.1"}``

Set the PXE interface
  ``export BIFROST_NETWORK_INTERFACE=${BIFROST_NETWORK_INTERFACE:-"ens4"}``

Inventory
---------

Finkle requires a basic inventory of hosts that includes OOB and other network information
in CSV format, including:

- name
- oob_driver (string) (ie. ipmi,redfish)
- oob_address (cidr)
- oob_username (string)
- oob_password (string)
- pxe_address (cidr)
- pxe_gateway (ip)
- pxe_nameserver (ip)
- pxe_macaddress (mac)

.. code-block:: bash

    name,oob_driver,oob_address,oob_username,oob_password,pxe_address,pxe_gateway,pxe_nameserver,pxe_mac_address
    123453-compute03,redfish,10.12.195.45,admin,p@ssw0rd123!,192.168.192.33/24,192.168.192.1,9.9.9.9,48:df:37:16:53:3c
    123454-compute04,redfish,10.12.195.46,admin,p@ssw0rd123!,192.168.192.34/24,192.168.192.1,9.9.9.9,48:df:37:16:53:44

To generate a Bifrost-friendly inventory file, execute the following from the finkle directory:

.. code-block:: bash

    ansible-playbook playbooks/create-inventory.yaml

The yaml file will be created that can be used by Bifrost for enrollment.

Enrolling
---------

To enroll nodes into Bifrost, execute the `enroll-dynamic.yaml` playbook from the bifrost directory:

.. code-block:: bash

    export BIFROST_INVENTORY_SOURCE=/opt/finkle/baremetal.yml
    cd /opt/bifrost/playbooks
    ansible-playbook -vvvv -i inventory/bifrost_inventory.py enroll-dynamic.yaml

Provisioning
------------

TBD

Using the Baremetal CLI
-----------------------

To use the Baremetal CLI, activate the Bifrost venv:

.. code-block:: bash

    export OS_CLOUD=bifrost
    source /opt/stack/bifrost/bin/activate
    baremetal node list

Example:

.. code-block:: bash

    ubuntu@bifrost-demo01:/opt/finkle$ export OS_CLOUD=bifrost
    ubuntu@bifrost-demo01:/opt/finkle$ source /opt/stack/bifrost/bin/activate
    (bifrost) ubuntu@bifrost-demo01:/opt/finkle$ baremetal node list
    +--------------------------------------+------------------+---------------+-------------+--------------------+-------------+
    | UUID                                 | Name             | Instance UUID | Power State | Provisioning State | Maintenance |
    +--------------------------------------+------------------+---------------+-------------+--------------------+-------------+
    | 9bf0eca8-6ed0-4652-9c4b-ff2cfed183d9 | 935821-compute03 | None          | None        | available          | True        |
    | d37db350-ab47-443a-bc36-0c7920980624 | 935822-compute04 | None          | None        | available          | True        |
    +--------------------------------------+------------------+---------------+-------------+--------------------+-------------+
