#!/bin/bash

cd /

if [ -z "$*" ]; then
  echo "$0 requires at least one argument (path to package to install)."
  exit 1
else
  packages_to_install=$*
  echo "Going to run integration tests on $packages_to_install"
fi

if [ -e /opt/puppet-omnibus ]; then
  echo "puppet-omnibus looks like is already here?"
  exit 1
fi

apt-get install virt-what libgmp10 libxml2 libxslt1.1 libssl1.0.0 libssl1.0-dev --yes --force-yes
if dpkg -i $packages_to_install; then
  echo "Looks like it installed correctly"
else
  echo "Dpkg install failed"
  exit 1
fi

if [ -d /opt/puppet-omnibus ]; then
  echo "puppet-omnibus looks like it exists"
else
  echo "puppet-omnibus doesnt look like it is installed"
  exit 1
fi

if /opt/puppet-omnibus/bin/puppet --version; then
  echo "puppet-omnibus looks like it Works!"
else
  echo "puppet-omnibus --version failed"
  exit 1
fi

COUNT=$(find /opt/puppet-omnibus/embedded/lib/ruby/gems/*/gems/puppet-[0-9]* -maxdepth 0 | wc -l)
if [ "$COUNT" == "1" ]; then
  echo "We have exactly 1 puppet gem version installed"
else
  echo "We have $COUNT puppet gem versions installed, not 1"
  exit 1
fi

set -e
(/opt/puppet-omnibus/embedded/bin/gem list | grep -q augeas) || (echo "Augeas gem is missing" && exit 1)
(/opt/puppet-omnibus/embedded/bin/gem list | grep -q aws-sdk) || (echo "AWS-SDK gem is missing" && exit 1)
