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
