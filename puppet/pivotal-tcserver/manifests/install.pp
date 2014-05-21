## vFabric Web Server Puppet Module
##
## Copyright 2013 GoPivotal, Inc
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
  $installed_base = '/opt/vmware/vfabric-tc-server-standard',
) {

  if defined('pivotal_repo') {
    package {'vfabric-tc-server-standard':
      ensure    => $version,
      install_options => [ { 'prefix' => $installed_base } ],
      require   => Exec['vfabric-eula-acceptance'],
    }
  } else {
    fail 'pivotal_repo module not included'
  }
}
