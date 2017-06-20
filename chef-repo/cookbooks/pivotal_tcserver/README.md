pivotal_tcserver Cookbook
=========================
This cookbook provides a definition which installs Pivotal tc Server and creates runtime instances.

iThis cookbook does installs the needed packages on the target nodes. When deleting instances it does not remove the package in case the admin wants to manually create and control instances. To remove the package use the Chef package resource.

Requirements
------------
#### cookbooks
- `pivotal_repo` - This is needed to install the Pivotal package repository
- A JDK already installed.
- /bin/sh should point to bash. On some systems, especially Ubuntu, /bin/sh points to a different shell. This is a requirement for tcruntime-instance.sh to run correctly.

Configuration
-------------
||name||definition
|java_home|The value to set JAVA_HOME environment variable to when invoking tcruntime-instance.sh (Required)
|instance_dir|The root directory to create the instance in. This defaults to the base path of tcruntime-instance.sh script (Optional)
|version|The value to give the --version argument. (Optional)
|layout|The value to give the --layout argument. (Optional)
|templates|An array of templates to use. (Optional)
|properties|An array of properties to pass to tcruntime-instance.sh (Optional)

Actions
-------
- :stop - Tells chef to stop the instance, if running
- :start - Tells chef to start the instance, if not already running
- :delete - Stops the instance and removes the entire contents of the instance directory. Caution: This action is destructive. This action does NOT remove the .rpm/.deb package.

Usage
-----
Your cookbook should depend on 'pivotal_webserver'

metadata.rb:
```ruby
depends "pivotal_tcserver"
```
You must set java_home to point to a valid JDK installation on the target system.

```ruby
tcruntime_instance "test1" do
  java_home "/usr/java"
end

```

Example of properties and templates
```ruby
tcruntime_instance "tcruntime-8081" do
  java_home "/usr/java"
  properties [{'bio.http.port' => '8081'}, {'bio.httpS.port' => '8444'}, {'base.jmx.port' => '6970'}]
  templates ['bio',  'bio-ssl']
end
```

License
-------
This cookbook is licensed under the Apache 2.0 License. It uses software which is licensed under commercial licenses.


