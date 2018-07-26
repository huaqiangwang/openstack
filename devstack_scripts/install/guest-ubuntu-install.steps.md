# Notes for Building up Guest Environment

## Network
### Check libvirt default bridge 'virbr0'<BR>
Referrint to [libvirt Network](https://wiki.libvirt.org/page/Networking)

NAT forwarding (aka "virtual networks")
Host configuration
Every standard libvirt installation provides NAT based connectivity to virtual
machines out of the box. This is the so called 'default virtual network'. You
can verify that it is available with

```shell
# virsh net-list --all
Name                 State      Autostart
-----------------------------------------
default              active     yes
```
If it is missing, then the example XML config can be reloaded & activated

``` shell
# virsh net-define /usr/share/libvirt/networks/default.xml
Network default defined from /usr/share/libvirt/networks/default.xml
# virsh net-autostart default
Network default marked as autostarted
# virsh net-start default
```
Network default started
When the libvirt default network is running, you will see an isolated bridge device.
 This device explicitly does *NOT* have any physical interfaces added, since it
  uses NAT + forwarding to connect to outside world. Do not add interfaces

``` shell
# brctl show
```
bridge name	bridge id		STP enabled	interfaces
virbr0		8000.000000000000	yes
Libvirt will add iptables rules to allow traffic to/from guests attached to the
 virbr0 device in the INPUT, FORWARD, OUTPUT and POSTROUTING chains. It will
  also attempt to enable ip_forward. Some other applications may disable it,
   so the best option is to add the following to /etc/sysctl.conf
```code
 net.ipv4.ip_forward = 1
```
If you are already running dnsmasq on your machine, please see libvirtd and
dnsmasq.

Guest configuration
Once the host configuration is complete, a guest can be connected to the virtual
network based on the network name. E.g. to connect a guest to the 'default'
 virtual network, you need to edit the domain configuration file for this guest:

```shell
  virsh edit <guest>
```
where <guest> is the name or uuid of the guest. Add the following snippet
of XML to the config file:

```code
  <interface type='network'>
     <source network='default'/>
     <mac address='00:16:3e:1a:b3:4a'/>
  </interface>
```
N.B. the MAC address is optional and will be automatically generated if omitted.
### Network status
```code

david@openstack-vm-u9832:~$ ifconfig
ens3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.122.89  netmask 255.255.255.0  broadcast 192.168.122.255
        inet6 fe80::5054:ff:fe12:3456  prefixlen 64  scopeid 0x20<link>
        ether 52:54:00:12:34:56  txqueuelen 1000  (Ethernet)
        RX packets 11841  bytes 888169 (888.1 KB)
        RX errors 0  dropped 571  overruns 0  frame 0
        TX packets 11302  bytes 978301 (978.3 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 1321  bytes 90035 (90.0 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1321  bytes 90035 (90.0 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

david@openstack-vm-u9832:~$ ping 192.168.42.200
PING 192.168.42.200 (192.168.42.200) 56(84) bytes of data.
64 bytes from 192.168.42.200: icmp_seq=1 ttl=64 time=0.272 ms
^C
--- 192.168.42.200 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.272/0.272/0.272/0.000 ms
david@openstack-vm-u9832:~$ ping 192.168.42.1
PING 192.168.42.1 (192.168.42.1) 56(84) bytes of data.
64 bytes from 192.168.42.1: icmp_seq=1 ttl=63 time=0.315 ms
^C
--- 192.168.42.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.315/0.315/0.315/0.000 ms

david@openstack-vm-u9832:~$ ssh -fNL 19192:xxxx.proxy.com:9x1 huaqiang@192.168.42.1
Could not create directory '/home/david/.ssh'.
The authenticity of host '192.168.42.1 (192.168.42.1)' can't be established.
ECDSA key fingerprint is SHA256:EEHiPOo4yMDsIBvM00dc06rLp3vEyJwtHMr3DoXsVO0.
Are you sure you want to continue connecting (yes/no)? yes
Failed to add the host to the list of known hosts (/home/david/.ssh/known_hosts).
huaqiang@192.168.42.1's password:


david@openstack-vm-u9832:~$ sudo apt-get update
Get:1 http://security.ubuntu.com/ubuntu artful-security InRelease [83.2 kB]
Hit:2 http://us.archive.ubuntu.com/ubuntu artful InRelease
Get:3 http://security.ubuntu.com/ubuntu artful-security/main amd64 Packages [176 kB]
Get:4 http://us.archive.ubuntu.com/ubuntu artful-updates InRelease [88.7 kB]
Get:5 http://security.ubuntu.com/ubuntu artful-security/main i386 Packages [174 kB]
Get:5 http://security.ubuntu.com/ubuntu artful-security/main i386 Packages [174 kB]
Get:5 http://security.ubuntu.com/ubuntu artful-security/main i386 Packages [174 kB]
Get:8 http://security.ubuntu.com/ubuntu artful-security/main Translation-en [80.1 kB]
Get:9 http://us.archive.ubuntu.com/ubuntu artful-backports InRelease [74.6 kB]
0% [9 InRelease 957 B/74.6 kB 1%] [8 Translation-en 4074 B/80.1 kB 5%]                                                                               49.5 kB/s 26s^C
david@openstack-vm-u9832:~$ ps aux|grep ssh
root      3190  0.0  0.2  72136  5708 ?        Ss   10:46   0:00 /usr/sbin/sshd -D
root      4098  0.0  0.3 105604  7208 ?        Ss   11:03   0:00 sshd: david [priv]
david     4159  0.1  0.2 105604  4608 ?        S    11:04   0:00 sshd: david@pts/0
david     4225  0.0  0.1  46736  2880 ?        Ss   11:06   0:00 ssh -fNL 19192:proxy.xxxx.com:9x1 huaqiang@192.168.42.1
david     4591  0.0  0.0  13040  1044 pts/0    S+   11:09   0:00 grep ssh
david@openstack-vm-u9832:~$ cat /etc/apt/apt.conf.d/90proxy
Acquire::https::Proxy "http://127.0.0.1:19192";
Acquire::http::Proxy "http://127.0.0.1:19192";

```

### Proxy Setting
After above configuration, a NAT network should work at our desire, and the
guest os could reach outside network.
But sometimes the proxy is required to access world-wide network.
here is the way to setup a proxy through a jumper machine
```shell
ssh -fNL [localhostPort]:hostipAcessingInternet:hostAccessingInternetPort \
user@jumperMachineIP:port
```

### apt configuration
```
david@openstack-vm-u9832:~$ cat /etc/apt/apt.conf.d/90proxy
Acquire::http::Proxy "http://127.0.0.1:19192";
```
until now, the 'apt-get update' command should work.
