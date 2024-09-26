## Pivotal RPM/DEB Repository Module
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
##
## Configuration Information
##
##  $ensure
##    Default - installed
##    The state of the repository
##
##  $i_accept_eula
##    Default - false
##    When true this indicates that the Pivotal EULA is accepted which allows
##    the repository to be installed.

class pivotal_repo (
  $ensure = installed,
  $app_suite_repo_version = '1.0-4',
  $i_accept_eula = false
  ) {

  if $i_accept_eula {
    case $::operatingsystem {
      'RedHat', 'CentOS': {
        $org_name = 'vmware' # Red Hat YUM repo uses vmware
        $package_name = "app-suite-repo"
        $cmd = "/etc/pivotal/pivotal-eula-acceptance.sh --accept_eula_file=Pivotal_EULA.txt > /dev/null 2>&1"
        $rhel_release = $::operatingsystemrelease ? {
          /^5/    => '5',
          /^6/    => '6',
          default => Fail["OS Release ${::operatingsystemrelease} not supported at this time"]
        }
        $pivotal_repo_url = "http://packages.gopivotal.com/pub/rpm/rhel${rhel_release}/app-suite/app-suite-repo-${app_suite_repo_version}.noarch.rpm"
        $pivotal_gpg_url = "http://packages.gopivotal.com/pub/rpm/rhel${rhel_release}/app-suite/RPM-GPG-KEY-PIVOTAL-APP-SUITE-EL${rhel_release}"
        exec { 'gpg_import':
          command => "/bin/rpm --import ${pivotal_gpg_url}",
          creates => "/etc/pki/rpm-gpg/RPM-GPG-KEY-PIVOTAL-APP-SUITE-EL${rhel_release}"
        } ->
        # The Repo RPM installs the acceptance script so instead of maintaining the repo with a yumrepo resource we have to install
        # the rpm ourselves.
        package { $package_name:
          ensure   => $ensure,
          provider => 'rpm',
          source   => $pivotal_repo_url,
          before   => Exec['pivotal-eula-acceptance']
        }
      }
      'Ubuntu': {
        $org_name = 'pivotal' # Ubuntu apt repo uses pivotal
        $pivotal_repo_package_gpgurl = 'http://packages.pivotal.io/pub/apt/ubuntu/DEB-GPG-KEY-PIVOTAL-APP-SUITE'
        $cmd = "/etc/pivotal/app-suite/pivotal-eula-acceptance.sh --accept_eula_file=Pivotal_Software_EULA--8.4.14.txt > /dev/null 2>&1"
        $pivotal_repo_package_url = $::operatingsystemrelease ? {
          /^10.04/ => 'http://packages.pivotal.io/pub/apt/ubuntu/pivotal-app-suite-repo-lucid_1.0-5_all.deb',
          /^12.04/ => 'http://packages.pivotal.io/pub/apt/ubuntu/pivotal-app-suite-repo-precise_1.0-5_all.deb',
          default  => Fail["OS Release ${::operatingsystemrelease} not supported at this time"]
        }
        $package_name = $::operatingsystemrelease ? {
          /^10.04/ => 'pivotal-app-suite-repo-lucid',
          /^12.04/ => 'pivotal-app-suite-repo-precise'
        }
        class { 'apt':
          update    => {
            frequency => 'always',
          },
        } ->
        apt::key {'pivotal-app-suite':
          key        => '7C4B3B36',
          key_source => 'http://packages.pivotal.io/pub/apt/ubuntu/DEB-GPG-KEY-PIVOTAL-APP-SUITE'
        } ->
        wget::fetch { $pivotal_repo_package_url :
          destination => "/tmp/${package_name}.deb",
          timeout     => 0,
          verbose     => false,
        } ->
        package { $package_name:
          ensure   => $ensure,
          provider => 'dpkg',
          source   => "/tmp/${package_name}.deb",
          before   => Exec['pivotal-eula-acceptance']
        }
        exec { 'apt-update':
          command      => '/usr/bin/apt-get update',
        }
        Exec['apt-update'] -> Package <| |>
      }
      default: {
        fail "OS ${::operatingsystem} not supported at this time"
      }
    }
    exec { 'pivotal-eula-acceptance':
      command => $cmd,
      require => Package[$package_name]
    }
  } else {
    fail "[${::fqdn}] You must accept the terms of the EULA located at http://www.vmware.com/download/eula/vfabric_app-platform_eula.html"
  }
}
