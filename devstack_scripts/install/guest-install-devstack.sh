function protocal_https_replace_git
{
  git config --global url."https://".insteadOf git://
  git config --global https.proxy htp://127.0.0.1:19192
  git config --global http.proxy http://127.0.0.1:19192
}

function setup_openstack_github_source
{
  protocal_https_replace_git
  git clone http://git.trystack.cn/openstack-dev/devstack -b stable/rocky
  cd devstack
  if [ -f local.conf ]
  then
    mv local.conf local.conf-`date +%M`
  fi

  tee local.conf >>/dev/null <<EOF
[[local|localrc]]
HOST_IP=127.0.0.1
SERVICE_HOST=127.0.0.1
ADMIN_PASSWORD=secure
DATABASE_PASSWORD=secure
RABBIT_PASSWORD=secure
SERVICE_PASSWORD=secure
# use TryStack git mirror
GIT_BASE=http://git.trystack.cn
NOVNC_REPO=http://git.trystack.cn/kanaka/noVNC.git
SPICE_REPO=http://git.trystack.cn/git/spice/spice-html5.git
EOF

./stack.sh

}

setup_openstack_github_source
