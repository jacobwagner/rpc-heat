cat > .ssh/id_rsa << "EOF"
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEApKLsDVhO90q1Elj+wMR/vFlyOS04DznEsRIZrq6o8JGpEV73
pWm0HZyOqob4ccVp4bSH68NwETQFDDUs16tDCQMo4iqCSP50gX7k8KvUEvK415tY
meynB3jaUvx+p2/GicszDtn71TUOCelmBcizwR96Vw3khvvbFvBZtllAvNPex9K/
5gltPk/F937WlDhTvOReeBGpeP+IBuxHmAGM3Qk5YhZaMqouf0i6Njag1LD6PjeO
PEcmnUe6wqk8qAn9pB5pg8wUjQc1tGKXwbc0WVkp5PBkc/u1Ho5EJbf2pZ7tpEW7
fS8f6KEVQ6h5AWYQw0hSh5BMOJi9w2mncscboQIDAQABAoIBAQCXBpmR2FuAAHlA
XoE7pkYjKs5cYv3VAcJMSPVkR/bT0FsOg1ab1+6RZ2d8SRopi9YIZYp2HS91qImk
3DbJlOKGpu5fIm2ntjx7+kLcAFQoGZ60sl3BvdSvRw7IJ7WrtR6kktHAovigae35
67BaR/WViGG68BSeOvWNAmjZnOCFFkHTdf5XCR068v1DgOg889ymaEbh9OnY2s50
BUiM34J777Za9TdErwsRvSO9CYHCy0utfcMN6Acs+IoZle+UcONYyw6h3M1WudwQ
jxlLCEJtypjRxJHKDWs4jKM2WhQMQJUSstjaQCwTr+KYH9gG849E9okgWMarZGCh
n2ZRL5ABAoGBAM5LHVoM3tCE85yoO4fVoAQUqNjHCwmWqIEE1ss8PxYimWVMfbjp
YIN1nGNxVdQuzZzz9gU9M2N7XLKn8yQSI3qv47YPrAwODs0Xs+pklSGSeq4dV7gC
ZzEY6VQAhZbw7muAFZbDPiKAylTqLg8NVRoDyxifyApRrJrQYDLF5uwhAoGBAMxO
Qru6XWPukMeAHM01w97FQ+9sEbFHq4jjjbkFODO7VaBaRk4MCCxoYSDSJmNbog7u
YgxwydOOc+3M/6XIRNlc+tWZwv6UoY355OOlpNzWdVQR+RtvkcJtKYksTFn/lsMD
oDNRn5RtpJr4h4Y4Z2nPugH2HafuvG1kPvGLjj+BAoGAU1Ye3mDyphP/gdqoaeBP
yzY5W5FVESOOoMg+qU2GQr/pbfWvmEKXHaQmcDm5rYTWxT/8s/McTmTodrfITlsR
gB+MAuFj5F7NdebMZLULVcuhybLK2+gEnd3tbGTlkqtz9XOBxSzMbg3PLuyHfMcr
CN5dbm4l1p1V+BiTtA8kkWECgYEAoumo9w811zDty9eRn+VGigYdFPbE6Otwkhh5
81aBKWcxcUtrEmMvxVF6WfSZXdM819Eo6CisF4FZWf+Ev4qBtB4bemZBAkY8yPzC
kvCMFPkB2Ab47/K4dSQc4eAsBfv0GQ90GFf2+yGvB1A0qUei1tIozdWWcknBgS1V
r8CLroECgYApgl9fhrOI2uxjKJMUAZ07JnOqn2pIZnjGtJTbyCKsQt4JpS2/bDUG
LiSDlee56d1iOWKBWBz2/i1EHFqhW1GFDM448vA0C3pwZc72OlmugEonRyRXbKL2
ptG+vgOPUKOdkjtR9HUveHgm+PrQjs7mx0GhzV8Y2RKN9ENJw+AAyQ==
-----END RSA PRIVATE KEY-----
EOF

chmod 600 .ssh/*

cd /root
git clone -b $version https://github.com/rcbops/ansible-lxc-rpc.git
cd ansible-lxc-rpc
pip install -r requirements.txt
cp -a etc/rpc_deploy /etc/
scripts/pw-token-gen.py --file /etc/rpc_deploy/user_variables.yml
echo "nova_virt_type: qemu" >> /etc/rpc_deploy/user_variables.yml

environment_version=$(md5sum /etc/rpc_deploy/rpc_environment.yml | awk '{print $1}')

cat > /etc/rpc_deploy/rpc_user_config.yml << EOF
---
# Copyright 2014, Rackspace US, Inc.
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

# This is the md5 of the environment file
# this will ensure consistency when deploying.
environment_version: ${environment_version}

# User defined CIDR used for containers
# Global cidr/s used for everything.
cidr_networks:
  # Cidr used in the Management network
  container: 172.29.236.0/22
  # Cidr used in the Service network
  snet: 172.29.248.0/22
  # Cidr used in the VM network
  tunnel: 172.29.240.0/22
  # Cidr used in the Storage network
  storage: 172.29.244.0/22

# User defined list of consumed IP addresses that may intersect
# with the provided CIDR.
used_ips:
  - 172.29.236.1,172.29.236.50
  - 172.29.244.1,172.29.244.50

# As a user you can define anything that you may wish to "globally"
# override from within the rpc_deploy configuration file. Anything
# specified here will take precedence over anything else any where.
global_overrides:
  # Internal Management vip address
  internal_lb_vip_address: 172.29.236.3
  # External DMZ VIP address
  external_lb_vip_address: 134.213.57.93
  # Bridged interface to use with tunnel type networks
  tunnel_bridge: "br-vxlan"
  # Bridged interface to build containers with
  management_bridge: "br-mgmt"
  # Define your Add on container networks.
  #  group_binds: bind a provided network to a particular group
  #  container_bridge: instructs inventory where a bridge is plugged
  #                    into on the host side of a veth pair
  #  container_interface: interface name within a container
  #  ip_from_q: name of a cidr to pull an IP address from
  #  type: Networks must have a type. types are: ["raw", "vxlan", "flat", "vlan"]
  #  range: Optional value used in "vxlan" and "vlan" type networks
  #  net_name: Optional value used in mapping network names used in neutron ml2
  # You must have a management network.
  provider_networks:
    - network:
        group_binds:
          - all_containers
          - hosts
        type: "raw"
        container_bridge: "br-mgmt"
        container_interface: "eth1"
        ip_from_q: "container"
    - network:
        group_binds:
          - glance_api
          - cinder_api
          - cinder_volume
          - nova_compute
        type: "raw"
        container_bridge: "br-storage"
        container_interface: "eth2"
        ip_from_q: "storage"
    - network:
        group_binds:
          - glance_api
          - nova_compute
          - neutron_linuxbridge_agent
        type: "raw"
        container_bridge: "br-snet"
        container_interface: "eth3"
        ip_from_q: "snet"
    - network:
        group_binds:
          - neutron_linuxbridge_agent
        container_bridge: "br-vxlan"
        container_interface: "eth4"
        ip_from_q: "tunnel"
        type: "vxlan"
        range: "10:1000"
        net_name: "vxlan"
    - network:
        group_binds:
          - neutron_linuxbridge_agent
        container_bridge: "br-vlan"
        container_interface: "eth5"
        type: "flat"
        net_name: "vlan"
  # Name of load balancer
  lb_name: lb_name_in_core

# User defined Infrastructure Hosts, this should be a required group
infra_hosts:
  heat-controller-1:
    ip: 172.29.236.1
  heat-controller-2:
    ip: 172.29.236.2
  heat-controller-3:
    ip: 172.29.236.3

# User defined Compute Hosts, this should be a required group
compute_hosts:
  heat-compute-1:
    ip: 172.29.236.4
  heat-compute-2:
    ip: 172.29.236.5

# User defined Storage Hosts, this should be a required group
storage_hosts:
  heat-compute-1:
    ip: 172.29.236.4
    # "container_vars" can be set outside of all other options as
    # host specific optional variables.
    container_vars:
      # In this example we are defining what cinder volumes are
      # on a given host.
      cinder_backends:
        # if the "limit_container_types" argument is set, within
        # the top level key of the provided option the inventory
        # process will perform a string match on the container name with
        # the value found within the "limit_container_types" argument.
        # If any part of the string found within the container
        # name the options are appended as host_vars inside of inventory.
        limit_container_types: cinder_volume
        lvm:
          volume_group: cinder-volumes
          volume_driver: cinder.volume.drivers.lvm.LVMISCSIDriver
          volume_backend_name: LVM_iSCSI

# User defined Logging Hosts, this should be a required group
log_hosts:
  heat-controller-1:
    ip: 172.29.236.1

# User defined Networking Hosts, this should be a required group
network_hosts:
  heat-controller-2:
    ip: 172.29.236.2

haproxy_hosts:
  heat-controller-3:
    ip: 172.29.236.3
EOF

cd rpc_deployment
ansible-playbook -e @/etc/rpc_deploy/user_variables.yml playbooks/setup/host-setup.yml \
                                                        playbooks/infrastructure/haproxy-install.yml \
                                                        playbooks/infrastructure/infrastructure-setup.yml \
                                                        playbooks/openstack/openstack-setup.yml
