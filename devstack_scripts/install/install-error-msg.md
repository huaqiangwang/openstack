# Error Message Collections

## Host does not support domain type kvm for virtualization type 'exe' arch 'x86_64'
<pre>
[root@dl-c200 install]# ./install-vm.sh
ERROR    Host does not support domain type kvm for virtualization type 'exe' arch 'x86_64'
./install-vm.sh: line 83: [: ==: unary operator expected
</pre>
modified install command in such way:
<pre>
diff --git a/devstack_scripts/install/install-vm.sh b/devstack_scripts/install/install-vm.sh
index 40b98d8..0b995d7 100755
--- a/devstack_scripts/install/install-vm.sh
+++ b/devstack_scripts/install/install-vm.sh
@@ -43,6 +43,7 @@ install_vm() {
   fi

   NO_AT_BRIDGE=1  virt-install \
+      -v \
       --name $1\
       --memory 10240 \
       --disk $2,size=15 \
</pre>

This issue moves to a problem of next one.

## virsh capabilites', this machine does not support 'hvm'
<font color=Red>
** - Does that mean the libvirt does not support hvm** <br>
** - An issue of libvirt? -- Need futhur investigation **<br>
</font>
After enable --hvm for 'virt-install' with argument '-v', another error emerges
"The output of console ERROR    Host does not support virtualization type 'hvm'"
After looking for capabilites from command '!
kvm module status:
<pre>
[root@dl-c200 install]# lsmod |grep kvm
kvm_intel             155648  0
kvm                   602112  1 kvm_intel
irqbypass              16384  1 kvm
</pre>
