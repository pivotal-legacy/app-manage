## Pivotal tc Server Puppet Module
##
## Copyright 2013 Pivotal Software, Inc
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

class tcserver::install(
  $version = 'latest',
  $provider = 'pivotal',
) {


    case $provider {
      'pivotal': {
        if defined('pivotal_repo') {
          package {'pivotal-tc-server-standard':
            ensure  => $version,
            require => Exec['pivotal-eula-acceptance'],
          }
        } else {
          fail 'pivotal_repo module not included'
        }
      }
    'dpkg': {
      $package_version = "pivotal-tc-server-standard-${version}"
      $file_ext = 'deb'
      package {'pivotal-tc-server-standard':
        ensure   => present,
        provider => 'dpkg',
        source   => "/tmp/${package_version}.noarch.${file_ext}",
        require  => File["pivotal_tcserver_${file_ext}"],
      }
      file {"pivotal_tcserver_${file_ext}":
        ensure => file,
        source => "puppet:///modules/tcserver/${package_version}.noarch.${file_ext}",
        path   => "/tmp/${package_version}.noarch.${file_ext}",
      }
    }
    'rpm': {
      $package_version = "pivotal-tc-server-standard-${version}"
      $file_ext = 'rpm'
      package {'pivotal-tc-server-standard':
        ensure   => present,
        provider => 'rpm',
        source   => "/tmp/${package_version}.noarch.${file_ext}",
        require  => File["pivotal_tcserver_${file_ext}"],
      }
      file {"pivotal_tcserver_${file_ext}":
        ensure => file,
        source => "puppet:///modules/tcserver/${package_version}.noarch.${file_ext}",
        path   => "/tmp/${package_version}.noarch.${file_ext}",
      }
    }
    'local_repo': {
      case $::osfamily {
        'suse': {
          $package_provider = 'zypper'
        }
        'redhat': {
          $package_provider = 'yum'
        }
        'debian': {
          $package_provider = 'apt'
        }
        default: {
          fail("tcserver::install::provider::local_repo is not compatable with ${::osfamily}.")
        }
      }
      package {'pivotal-tc-server-standard':
        ensure   => $version,
        provider => $package_provider,
      }
    }
  }
}
