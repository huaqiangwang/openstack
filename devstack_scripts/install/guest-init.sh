#!/usr/bin/env bash

#
# Running under guest Ubuntu os
# for
# - proxy (apt, other generl network proxy)
# - apt mirror source
# - pip mirror source
# - openstack mirror source

FAKE_OUTPUT=1

if [ $FAKE_OUTPUT -eq 1 ]
then
  OUTPUT_PREFIX='/tmp'
else
  OUTPUT_PREFIX=''
fi


function createfile
{
  foldername=`dirname $1`
  filename=`basename $1`
  mkdir -p $foldername
  touch $foldername/$filename
}

function checkfile
{
  if [ $FAKE_OUTPUT == 1 ]
  then
    if [ ! -f $1 ]
    then
      createfile $1
    fi
  fi
}

# setup_proxy
# parameter:
#  $1: proxy host ip address
#  $2: porxy port
# return
#  0: success
function setup_proxy()
{
  ENVFILE_NAME="/etc/profile"
  if [ ! -f ${ENVFILE_NAME} ]
  then
    echo "${ENVFILE_NAME} not exist"
    exit
  fi

  checkfile ${OUTPUT_PREFIX}${ENVFILE_NAME}

  # check if proxy already defined
  origin_http_proxy=`grep "proxy_http[^s]" ${OUTPUT_PREFIX}${ENVFILE_NAME}`
  origin_https_proxy=`grep "proxy_https" ${OUTPUT_PREFIX}${ENVFILE_NAME}`
  if [ "$origin_http_proxy" == "" ]
  then
    echo "export proxy_http=$1:$2" >> ${OUTPUT_PREFIX}${ENVFILE_NAME}
  else
    echo "warnning: http proxy already exists in ${OUTPUT_PREFIX}${ENVFILE_NAME}"
    echo "${OUTPUT_PREFIX}${ENVFILE_NAME}: \"${origin_http_proxy}\""
  fi
  if [ "$origin_https_proxy" == "" ]
  then
    echo "export proxy_https=$1:$2" >> ${OUTPUT_PREFIX}${ENVFILE_NAME}
  else
    echo "--warnning: https proxy already exists in ${OUTPUT_PREFIX}${ENVFILE_NAME}"
    echo "${OUTPUT_PREFIX}${ENVFILE_NAME}: \"${origin_https_proxy}\""
  fi
}

# parameter:
#  $1: proxy host ip address
#  $2: porxy port
function setup_apt_proxy()
{
  if [ ! -d "/etc/apt/apt.conf.d/" ]
  then
    echo "No \"apt\" package found"
    exit
  fi

  checkfile $OUTPUT_PREFIX/etc/apt/apt.conf.d/50proxy

  origin_http_proxy=`grep "http::proxy" ${OUTPUT_PREFIX}/etc/apt/apt.conf.d/50proxy`
  origin_https_proxy=`grep "https::proxy" ${OUTPUT_PREFIX}/etc/apt/apt.conf.d/50proxy`
  if [ "$origin_http_proxy" == "" ]
  then
    echo "Acquire::http::proxy \"$1:$2/\";" >> ${OUTPUT_PREFIX}/etc/apt/apt.conf.d/50proxy
  else
    echo "-- warnning: http proxy already exists in ${OUTPUT_PREFIX}/etc/apt/apt.conf.d/50proxy"
    echo "${OUTPUT_PREFIX}/etc/apt/apt.conf.d/50proxy: \"${origin_http_proxy}\""
  fi
  if [ "$origin_https_proxy" == "" ]
  then
    echo "Acquire::https::proxy \"$1:$2/\";" >> ${OUTPUT_PREFIX}/etc/apt/apt.conf.d/50proxy
  else
    echo "-- warnning: https proxy already exists in ${OUTPUT_PREFIX}/etc/apt/apt.conf.d/50proxy"
    echo "${OUTPUT_PREFIX}/etc/apt/apt.conf.d/50proxy: \"${origin_https_proxy}\""
  fi
}

function setup_apt
{
  TARGET="${OUTPUT_PREFIX}/etc/apt/sources.list"

  checkfile $TARGET

  if [ ! -f $TARGET ]
  then
    echo "$TARGET does not exist"
    exit
  fi

  codename=`lsb_release -c |awk -F " " '/Codename/ {print $2}'`
  if [ "$codename" == "" ]
  then
    echo "Are you working on Ubuntu, check with lsb_release!"
    exit
  fi

  mv $TARGET $TARGET-`date +%M`
  tee $TARGET >>/dev/null  <<EOF
  deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $codename main restricted universe multiverse
  deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $codename-updates main restricted universe multiverse
  deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $codename-backports main restricted universe multiverse
  deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $codename-security main restricted universe multiverse

EOF
  if [ $FAKE_OUTPUT == 1 ]
  then
    apt-get update -y
  fi
}

function setup_pypi_source
{
  TARGET="${OUTPUT_PREFIX}/etc/pip.conf"

  checkfile $TARGET

  if [ ! -f $TARGET ]
  then
    echo "$TARGET does not exist"
    exit
  fi

  mv $TARGET $TARGET-`date +%M`
  tee $TARGET >>/dev/null  <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
}

function protocal_https_replace_git
{
  git config --global url."https://".insteadOf git://
}

function setup_openstack_github_source
{
  useradd -s /bin/bash -d /opt/stack -m stack
  echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
  sudo su - stack
  git clone https://git.openstack.org/openstack-dev/devstack
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
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

proxyip="127.0.0.1"
proxyport="19192"
setup_proxy $proxyip $proxyport
setup_apt_proxy $proxyip $proxyport
setup_apt
setup_pypi_source
protocal_https_replace_git
setup_openstack_github_source
