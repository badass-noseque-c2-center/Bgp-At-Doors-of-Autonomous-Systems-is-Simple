
# Table of Contents

1.  [FRR](#org0d5ea1c)
    1.  [Configuration](#orga2ce7d3)
2.  [Setup](#orgeec0c17)
    1.  [Virtual Machine](#org879fc28)
        1.  [VM first steps](#org7b620de)
        2.  [Building images for GNS3](#org809073a)
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


<a id="org879fc28"></a>

## Virtual Machine

First and foremost we'll need our VM to run GNS3. If you don't have the image yet, you have two make options here:

-   `make vm-create`: To create the VM by inserting the image in qemu as a CD.
-   `make vm-start`: To start the VM once created (i.e. image installed in the drive).

Both options will download the image if not present and start the VM, for this you'll need to have installed in your system `qemu-system-x86_64`. All this steps will be, of course, run from your **host** machine.


<a id="org7b620de"></a>

### VM first steps

Once the VM is installed and running, you'll need to perform this steps **each** time the VM starts:

-   **mount** this project folder in the VM. You can of course automatically do that with fstab. One example of manually mounting would be:
    
        sudo mount -t 9p -o trans=virtio,version9p2000.L p1 /mnt/shared

-   Run `make setup-host`. This will set up your VM installing needed packages, including GNS3, and setting up the network interfaces in order to debug from your host.


<a id="org809073a"></a>

### Building images for GNS3

The makefile will automatically build the images needed for GNS3, at this point two templates are present: `pc` just a minimal template acting as a user in the network; and `router` just like `pc` but with `frr` service activated at entrypoint. In order to build and run/test you have two options:

-   `make debug`: Will build the images and run them locally in your guest (localhost address), so they are accessible in you host machine by ssh starting at port **2230** (`ssg gns3@localhost -p 2230`).
-   `make build`: Will build the images prepared to be used by GNS3. You need to add them as a template in GNS3 in order to be run. Once running they can also be accessible from your host at the same port as before.

Images are in `images/`. The address, mask, port, and gateway can be set in the `.env` file if desired, but in GNS3 the same parameters found in `.env` must be copied in the environment variables from the template configuration wizard. This way addresses and others can be dynamically changed from GNS3.

In order to access the GNS3 machines from your host they must have an address in the TAP interface created in `make setup-host` (`10.0.10.*`). To do that, connect the to a GNS3-cloud node and select the tap interface from this node.


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

