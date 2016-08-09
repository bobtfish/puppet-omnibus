#!/usr/bin/env ruby
# This is basically a Docker file but with ruby for convenience.
#
# Run all your usual docker directives(lowcase though) and they will each
# be translated into a single line in Dockerfile
#
# e.g.:
#   run "hello"
# is equal to
#   RUN hello
#
# Multiple lines are stripped and joined with '; '
#
#   |run %Q{
#   |  foo
#   |  bar
#   |  this is new line \
#   |    this is not
#   |}
#
# translates into
#
#   RUN foo; bar; this is new line     this is not
#                                   ∧
#                                   |
#           note the spaces here ---'

$:.unshift '.'
require 'lib/docker'
extend Docker

OS_SOURCES = {
  'lucid'   => 'docker-dev.yelpcorp.com/lucid_yelp:latest',
  'precise' => 'docker-dev.yelpcorp.com/precise_yelp:latest',
  'trusty'  => 'docker-dev.yelpcorp.com/trusty_yelp:latest',
  'xenial'  => 'docker-dev.yelpcorp.com/xenial_yelp:latest'
}

from OS_SOURCES[env_os]

packages = {}
packages['deb'] = %w{
  autoconf bison build-essential curl fakeroot libgdbm-dev libgnutls-dev
  libncurses5-dev libpcre3-dev libsqlite3-dev libssl-dev libxslt1-dev
  pkg-config screen sudo wget zlib1g zlib1g-dev
  git-core libxml2-dev ruby gawk }

packages['tplx']    = packages['deb'] + %w{libffi6 libffi-dev libreadline6 libreadline6-dev}
packages['lucid']   = packages['tplx'] - %w{libffi6} + %w{libffi5}
packages['precise'] = packages['trusty'] = packages['xenial'] = packages['tplx']

run <<-SHELL, '&&'
  rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
  export DEBIAN_FRONTEND=noninteractive
  apt-get -q -qq update
  apt-get -q -qq --yes --force-yes install #{packages[env_os].sort.join(' ')}
SHELL

run <<-SHELL, '&&' if env_os == 'lucid'
  wget http://security.ubuntu.com/ubuntu/pool/main/c/ca-certificates/ca-certificates_20160104ubuntu0.14.04.1_all.deb
  wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/openssl_1.0.1f-1ubuntu2.19_amd64.deb
  dpkg -i openssl_1.0.1f-1ubuntu2.19_amd64.deb ca-certificates_20160104ubuntu0.14.04.1_all.deb
  rm openssl_1.0.1f-1ubuntu2.19_amd64.deb ca-certificates_20160104ubuntu0.14.04.1_all.deb
SHELL

# user jenkins
run <<SHELL, '&&'
  useradd jenkins
  mkdir -p /home/jenkins
  chown jenkins: -R /home/jenkins
  chsh -s /bin/bash jenkins
  rm -f /bin/sh
  ln -s /bin/bash /bin/sh
  touch "/etc/default/puppet"
  mkdir -p /opt /package /etc/puppet /var/lib/puppet /var/cache/omnibus
  chown jenkins: /opt /package /etc/puppet /var/lib/puppet /var/cache/omnibus "/etc/default/puppet"
  echo 'gem: --no-document' > /etc/gemrc
  echo 'install: --no-ri --no-rdoc' >> /etc/gemrc
  echo 'update: --no-ri --no-rdoc' >> /etc/gemrc
  cp /etc/gemrc /.gemrc
  cp /etc/gemrc /root/.gemrc
  cp /etc/gemrc /package/.gemrc
  cp /etc/gemrc /home/jenkins/.gemrc
SHELL

# ruby2.2.5
add "ruby-build-20160602.tar.gz /tmp"
run <<SHELL, '&&'
  mkdir -p /opt/puppet-omnibus/embedded
  export MAKE_OPTS="-j3 -s"
  export RUBY_CFLAGS=-Os
  export RUBY_BUILD_CACHE_PATH=/tmp
  export RUBY_CONFIGURE_OPTS="--without-gdbm --without-dbm --disable-install-doc --without-tcl --without-tk"
  /tmp/ruby-build-20160602/bin/ruby-build -p 2.2.5 /opt/puppet-omnibus/embedded
  chown -R jenkins: /opt/puppet-omnibus
  /opt/puppet-omnibus/embedded/bin/gem update --system >/dev/null
  rm -rf /opt/puppet-omnibus/embedded/share/*
SHELL

