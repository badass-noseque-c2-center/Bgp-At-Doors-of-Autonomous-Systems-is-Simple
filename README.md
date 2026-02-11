
# Table of Contents

1.  [Setup ssh connection between GNS3 nodes and Host machine](#orgda52dcf)
    1.  [Create a TAP interface](#orgc97c830)
    2.  [Connect to tap interface](#org2b4e8fd)
    3.  [Setup the GNS3 machine](#org6214c32)
    4.  [Bridge the connection to the host](#orgeb5d288)



<a id="orgda52dcf"></a>

# Setup ssh connection between GNS3 nodes and Host machine


<a id="orgc97c830"></a>

## Create a TAP interface

    sudo chown root:netdev /dev/net/tun
    sudo useradd -g $USER netdev
    sudo tunctl -u $USER -g netdev -t tap0
    sudo ifconfig tap0 10.0.1.1 netmask 255.255.255.0 up


<a id="org2b4e8fd"></a>

## Connect to tap interface

-   Create a cloud node.
-   In configuration add the newly created TAP interface.
-   New connection should be available now for the tap interface.
-   Connect the new tap interface to the machine you want expose.


<a id="org6214c32"></a>

## Setup the GNS3 machine

-   Configure the machine interface so it has an address in the range of the newly created tap interface (e.g. If tap interface is `10.0.1.1/24`, the machine could be `10.0.1.2/24`).
-   Restart networking:
    
        sudo systemctl restart networking


<a id="orgeb5d288"></a>

## Bridge the connection to the host

-   SSH server should now be avalilabe to the virtual machine using the assigned machine IP
-   VirtualBox must be using NAT adapter and forwarding port 2222 for both guest and host.
-   Bridge te connection to the NAT interface:
    From Guest:
    
        socat TCP-LISTEN:2222,fork TCP:10.0.1.2:22
    
    From Host
    
        ssh <user>@localhost -p2222

Script:

    #!/bin/bash
    
    address=${1:-10.0.10.2}
    port=${2:-2222}
    
    socat TCP-LISTEN:$port,fork TCP:$address:22

