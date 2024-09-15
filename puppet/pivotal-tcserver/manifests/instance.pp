## tc Server Puppet Module
##
## Copyright 2013-2014 Pivotal Software, Inc
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
## Requirements
##   This module requires a working java installation
##
## Configuration Information
##
##  $ensure
##    Default - running
##    Specify the state for the instance. Valid values are
##    running, stopped, absent.
##
##  $base_dir
##    Default - /var/opt/pivotal/pivotal-tc-server-standard
##    The parent directory to create the instance in
##
##  $java_home
##    Default - JAVA_HOME environment variable
##    The value of JAVA_HOME which should be set for the instance.
##
##  $use_java_home
##    Default - true
##    Whether to use the --java-home argument to create the instance
##    If this is false then the instance will be expected to find
##    $JAVA_HOME environment variable to run
##
##  $apps_dir
##    Default - 'webapps'
##    The location on the instance to copy files from $apps_source
##
##  $apps_source
##    Default - 'puppet:///modules/tcserver/webapps'
##    The url to copy webapps from. This must be a valid puppet url
##
##  The remainder of the variables correspond to a tc server property
##  underscores(_) are used in place of hyphens(-)
##
## Ports are not checked for availability. If a port is specified and it is
## in use already the instance will fail to start and puppet will report
## a generic error starting the instance.

define tcserver::instance (
  $ensure = running,
  $templates = [],
  $use_java_home = true,
  $java_home = undef,
  $properties_file = undef,
  $properties = [],
  $layout = undef,
  $version = undef,
  $base_dir = '/var/opt/pivotal/pivotal-tc-server-standard',
  $user = undef,
  $group = undef,
  $apps_dir = 'webapps',
  $apps_source = 'puppet:///modules/tcserver/webapps',
  $deploy_apps = false,
){
  require tcserver

  if !$java_home {
    if $::env_java_home {
      $my_java_home = $::env_java_home
    } else {
      fail 'Please set the configuration variable java_home for this instance.'
    }
  } else {
    $my_java_home = $java_home
  }

  if !$user {
    $tcserver_user = $::tcserver::tcserver_user
  } else {
    $tcserver_user = $user
  }

  if !$group {
    $tcserver_group = $::tcserver::tcserver_group
  } else {
    $tcserver_group = $group
  }

  $cwd = $base_dir

  if $ensure == 'running' or $ensure == 'stopped' {
    tcruntime_instance {$name:
      templates          => $templates,
      properties         => $properties,
      version            => $version,
      layout             => $layout,
      properties_file    => $properties_file,
      java_home          => $my_java_home,
      use_java_home      => $use_java_home,
      instance_directory => $cwd,
      require            => Class['::tcserver::postinstall']
    }

    file { "${cwd}/${name}":
      ensure  => directory,
      owner   => $tcserver_user,
      group   => $tcserver_group,
      recurse => true,
      ignore  => "${cwd}/${name}/${apps_dir}",
      require => Tcruntime_instance[$name]
    }

    file { "/etc/init.d/tcserver-instance-${name}":
      ensure => link,
      target => "${cwd}/${name}/bin/init.d.sh",
    }

    tcserver::service {$name:
      ensure => $ensure,
      name   => $name,
      cwd    => $cwd,
    }

    if $deploy_apps {
      file { "${cwd}/${name}/${apps_dir}":
        recurse => true,
        source  => $apps_source
      }
    }
  } else {
    tcserver::service {$name:
      ensure => absent,
      name   => $name,
      cwd    => $cwd,
    }->
    file { "${cwd}/${name}":
      ensure => absent,
      force  => true
    }->
    file { "/etc/init.d/tcserver-instance-${name}":
      ensure => absent,
    }
  }
}
