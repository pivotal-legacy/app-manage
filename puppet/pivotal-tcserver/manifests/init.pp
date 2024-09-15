## Web Server Puppet Module
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
##  $version
##    Default - latest
##    Specifies the version of the tc-server package to install. When value is
##    latest then the latest version of the package available in repositories
##    will be used
##
##  $uses_templates
##    Default - true
##    Whether this installation should copy templates located in $template_source
##    Instances should still have the template option used to specify the desired
##    template
##
##  $templates_source
##    Default - puppet:///modules/tcserver/templates
##    The location of the template files to copy to the node. If the location is empty
##    then no files are copied. Must be a valid puppet url
##
##  $tcserver_user
##    Default - tcserver
##    The user to user for ownership of files. This variable should be left at
##    except for expert usage.
##
##  $tcserver_group
##    Default - pivotal
##    The user to user for ownership of files. This variable should be left at
##    except for expert usage.

class tcserver (
  $ensure = present,
  $version = 'latest',
  $tcserver_user = 'tcserver',
  $tcserver_group = 'pivotal',
  $uses_templates = true,
  $templates_source = 'puppet:///modules/tcserver/templates',
  ) {

  $installed_base = '/opt/pivotal/pivotal-tc-server-standard'

  if $ensure == absent {
    $package_ensure = absent
  } else {
    $package_ensure = $version
  }

  class {'tcserver::install':
    version  => $package_ensure,
  } ->
  class {'tcserver::postinstall':
    ensure         => $package_ensure,
    uses_templates => $uses_templates
  }
}

