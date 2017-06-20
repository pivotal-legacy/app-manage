Puppet::Type.type(:tcruntime_instance).provide(:tcruntime_instance) do
  INSTANCE_TCRUNTIME_CTL = '/bin/tcruntime-ctl.sh'

  confine :true => true

  def self.instances
    Dir.entries(resource[:instances_root]) do |e|
      if Dir.exists(e) 
        if File.exists(e + INSTANCE_TCRUNTIME_CTL)
          puts "Adding #{e} as instance"
          new(:name => Dir.basename(e))
        else
          puts "Ignoring #{e} as instance"
        end
      end
    end
  end

  def create
    # We create the command here so we can get the java_home variable from the manifest
    resource = @resource
    Puppet::Provider.has_command(:tcruntime_instance, "/opt/pivotal/pivotal-tc-server-standard/tcruntime-instance.sh" ) do
      environment :HOME => "/opt/pivotal/pivotal-tc-server-standard/"
      environment :JAVA_HOME => resource[:java_home]
    end

    all_opts = " "
    if resource[:templates] and resource[:templates].length > 0
      #  It seems that if a puppet array has a single element it arrives here as a string.
      if resource[:templates].respond_to?('join')
        template_opts = "-t " + resource[:templates].join(" -t ")
      else
        template_opts = "-t " + resource[:templates]
      end
      all_opts = all_opts + template_opts
    end
    
    if resource[:properties]
      property_opts = " "
      resource[:properties].each do |k,v|
        property_opts = property_opts + " -p #{k}=#{v} "
      end
      all_opts = all_opts + property_opts
    end

    if resource[:instance_directory]
      instance_directory_opt = "-i #{resource[:instance_directory]} "
      all_opts = all_opts + instance_directory_opt
    end

    if resource[:version]
      version_opt = "-v #{resource[:version]} "
      all_opts = all_opts + version_opt
    end

    if resource[:layout]
      layout_opt = "--layout #{resource[:layout]} "
      all_opts = all_opts + layout_opt
    end

    if resource[:properties_file]
      properties_file_opt = "-f #{resource[:properties_file]} "
      all_opts = all_opts + properties_file_opt
    end

    if resource[:use_java_home]
      java_home_opt = "--java-home #{resource[:java_home]} "
      all_opts = all_opts + java_home_opt
    end
    tcruntime_instance('create', resource[:name], *all_opts.split(" "))
  end

  def exists?
    File.exists?(resource[:instance_directory]  + "/" + (resource[:name]))
  end
end

