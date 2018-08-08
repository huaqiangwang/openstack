# Install OpenStack Environment with Devstack in Internal Network

## Host Requirement
- Ubuntu16.04

## Steps
1. Setting up network through port mapping
<pre>
   ssh -fNL 19192:proxy-server:proxy-port account@jumper-server
   #for example
   ssh -fNL 19192:prc-intel.com:911 root@192.168.42.1
</pre>
** <font color=red>19192</font> is the local port mapping to remote proxy server,
all network traffic has been redirected to this port except local host. **
2. Building up network proxy and using domestric mirror servers for apt,pip,and
openstack github
<pre>
  sudo ./guest-init.sh
</pre>
3. Install Openstack through devstack
<pre>
  su - stack
  ./guest-install-devstack.sh
</pre>
