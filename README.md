
# Table of Contents

1.  [FRR](#org0d5ea1c)
    1.  [Configuration](#orga2ce7d3)
2.  [Setup](#orgeec0c17)
    1.  [Auto Setup](#org3e5ab26)
    2.  [Manual setup ssh connection between GNS3 nodes and Host machine](#org8a07614)
        1.  [Create a TAP interface](#orgc97c830)
        2.  [Connect to tap interface](#org2b4e8fd)
        3.  [Setup the GNS3 machine](#org6214c32)
        4.  [Bridge the connection to the host](#orgeb5d288)



<a id="org0d5ea1c"></a>

# FRR


<a id="orga2ce7d3"></a>

## Configuration

In order to [configure frr](https://docs.frrouting.org/en/latest/setup.html#daemons-configuration-file) refer firs to the `/etc/frr/daemons` file (`images/router/config/daemons`) and enable the services as specified in the linked doc.

In the new version of frr there is no multiple configuration files. All the configuration goes to `/etc/frr/frr.conf` (`images/router/config/frr.conf`). Then every service will read the configuration parameters that it understands from this unique file, as explained in the [offical doc](https://docs.frrouting.org/en/latest/basic.html#integrated-config-file).


<a id="orgeec0c17"></a>

# Setup


<a id="org3e5ab26"></a>

## Auto Setup

To automatically setup your virtual machine for working with gns3 run use the Makefile:

    make setup-host

Default address and mask is: `10.0.10.` and `255.255.255.0`.

You can then use one of the multiple options to run/debug your containers, for example:

    make debug-router

Check the Makefile for more


<a id="org8a07614"></a>

## Manual setup ssh connection between GNS3 nodes and Host machine


<a id="orgc97c830"></a>

### Create a TAP interface

    sudo chown root:netdev /dev/net/tun
    sudo useradd -g $USER netdev
    sudo tunctl -u $USER -g netdev -t tap0
    sudo ifconfig tap0 10.0.1.1 netmask 255.255.255.0 up


<a id="org2b4e8fd"></a>

### Connect to tap interface

-   Create a cloud node.
-   In configuration add the newly created TAP interface.
-   New connection should be available now for the tap interface.
-   Connect the new tap interface to the machine you want expose.


<a id="org6214c32"></a>

### Setup the GNS3 machine

-   Configure the machine interface so it has an address in the range of the newly created tap interface (e.g. If tap interface is `10.0.1.1/24`, the machine could be `10.0.1.2/24`).
    Example of file `/etc/network/intrfaces`
    
        #
        # This is a sample network config, please uncomment lines to configure the network
        #
        
        # Uncomment this line to load custom interface files
        # source /etc/network/interfaces.d/*
        
        # Static config for eth0
        #auto eth0
        #iface eth0 inet static
        #	address 192.168.0.2
        #	netmask 255.255.255.0
        #	gateway 192.168.0.1
        #	up echo nameserver 192.168.0.1 > /etc/resolv.conf
        
        # DHCP config for eth0
        #auto eth0
        #iface eth0 inet dhcp
        #	hostname gns3debian-1
-   Restart networking:
    
        sudo systemctl restart networking


<a id="orgeb5d288"></a>

### Bridge the connection to the host

-   SSH server should now be avalilabe to the virtual machine using the assigned machine IP
-   VirtualBox must be using NAT adapter and forwarding port 2222 for both guest and host.
-   Bridge te connection to the NAT interface:
    From Guest:
    
        socat TCP-LISTEN:2222,fork TCP:10.0.1.2:22
    
    From Host
    
        ssh <user>@localhost -p 2222

