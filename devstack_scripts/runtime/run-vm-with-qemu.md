# Run VM with QEMU - Without help of libvirt
Qemu is very simple for configure 'hard disk', 'cpu' and 'memory', one vm could easily
be set up through following command
<pre>
qemu-system-x86_64 -hda /tmp/vm-disk.qcow2 -m 2048 -boot d -enable-kvm -cpu host -smp cores=88
</pre>

Following paragraph will describe some advanced part of qemu.
## Network
### virsh domiflist
<pre>
[david@dl-c200 runtime]$ sudo virsh domiflist vm-openstack
Interface  Type       Source     Model       MAC
-------------------------------------------------------
vnet2      bridge     virbr0     -           00:16:3e:0b:08:33
</pre>

<pre>
[david@dl-c200 runtime]$ sudo ifconfig
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 14373  bytes 15060220 (14.3 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 14373  bytes 15060220 (14.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:af:fd:57  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vnet2: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether e6:67:78:5e:74:f0  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

</pre>

<pre>
[david@dl-c200 runtime]$ brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.02428196af43       no
virbr0          8000.525400affd57       yes             virbr0-nic
                                                        vnet0
                                                        vnet2
</pre>

Above are messages of network of host.
vnet2 is NIC connecting the network that 'vm-openstack' belongs to.
virbr0 is a bridge connecting vnet2 and virbr0.
<br>
With appropriate 'iptable' command, 'vm-openstack' could access outside network
through the interface which is accessible to internet.

## What is Network TAP
[Wikipedia - TAP](https://en.wikipedia.org/wiki/Network_tap)

A Network TAP (Terminal Access Point) denotes a system which monitors events on a local network and in order to aid administrators (or attackers) in analyzing the network.[1] The tap itself is typically a dedicated hardware device, which provides a way to access the data flowing across a computer network. In many cases, it is desirable for a third party to monitor the traffic between two points in the network. If the network between points A and B consists of a physical cable, a "network tap" may be the best way to accomplish this monitoring. The network tap has (at least) three ports: an A port, a B port, and a monitor port. A tap inserted between A and B passes all traffic (send and receive data streams) through unimpeded in real time, but also copies that same data to its monitor port, enabling a third party to listen. Network taps are commonly used for network intrusion detection systems, VoIP recording, network probes, RMON probes, packet sniffers, and other monitoring and collection devices and software that require access to a network segment. Taps are used in security applications because they are non-obtrusive, are not detectable on the network (***having no physical or logical address***), can deal with full-duplex and non-shared networks, and will usually pass through or bypass traffic even if the tap stops working or loses power.

## What is Network Bridge
[Network Bridge](https://wiki.archlinux.org/index.php/Network_bridge)

A bridge is a piece of software used to unite two or more network segments. A bridge behaves like a virtual network switch, working transparently (the other machines do not need to know or care about its existence). Any real devices (e.g. eth0) and virtual devices (e.g. tap0) can be connected to it.
