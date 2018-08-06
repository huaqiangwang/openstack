#!/usr/bin/env bash

function protocal_https_replace_git
{
  git config --global url."https://".insteadOf git://
  git config --global https.proxy http://127.0.0.1:19192
  git config --global http.proxy http://127.0.0.1:19192
}

function setup_openstack_github_source
{
  protocal_https_replace_git
  git clone http://git.trystack.cn/openstack-dev/devstack
  cd devstack
  if [ -f local.conf ]
  then
    mv local.conf local.conf-`date +%M`
  fi

  tee local.conf >>/dev/null <<EOF
[[local|localrc]]
DMIN_PASSWORD=secret
ATABASE_PASSWORD=$ADMIN_PASSWORD
ABBIT_PASSWORD=$ADMIN_PASSWORD
ERVICE_PASSWORD=$ADMIN_PASSWORD
# use TryStack git mirror
GIT_BASE=http://git.trystack.cn
NOVNC_REPO=http://git.trystack.cn/kanaka/noVNC.git
SPICE_REPO=http://git.trystack.cn/git/spice/spice-html5.git
EOF
}

setup_openstack_github_source
