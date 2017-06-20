  # Class: rabbitmq::params
#
#   The RabbitMQ Module configuration settings.
#
class rabbitmq::params {

  case $::osfamily {
    'Debian': {
      $package_ensure   = 'installed'
      $package_name     = 'rabbitmq-server'
      $service_name     = 'rabbitmq-server'
      $package_provider = 'apt'
      $package_source   = ''
      $version          = 'latest'
      $group            = 'rabbitmq'
    }
    'RedHat': {
      $package_ensure   = 'installed'
      $package_name   = 'pivotal-rabbitmq-server'
      $package_provider = 'yum'
      $service_name     = 'rabbitmq-server'
      $version          = 'latest'
      $group            = 'pivotal'
      # This must remain at the end as we need $base_version and $version defined first.
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }

  #install
  $admin_enable               = true
  $erlang_manage              = false
  $management_port            = '15672'
  $package_apt_pin            = ''
  $package_gpg_key            = 'http://www.rabbitmq.com/rabbitmq-signing-key-public.asc'
  $service_ensure             = 'running'
  $service_manage             = true
  $cluster_disk_nodes         = []
  $cluster_node_type          = 'disc'
  $cluster_nodes              = []
  $config                     = 'rabbitmq/rabbitmq.config.erb'
  $config_cluster             = false
  $config_mirrored_queues     = false
  $config_path                = '/etc/rabbitmq/rabbitmq.config'
  $config_stomp               = false
  $default_user               = 'guest'
  $default_pass               = 'guest'
  $delete_guest_user          = false
  $env_config                 = 'rabbitmq/rabbitmq-env.conf.erb'
  $env_config_path            = '/etc/rabbitmq/rabbitmq-env.conf'
  $erlang_cookie              = 'EOKOWXQREETZSHFNTPEY'
  $manage_service             = true
  $node_ip_address            = 'UNSET'
  $plugin_dir                 = "/usr/lib/rabbitmq/lib/rabbitmq_server-${version}/plugins"
  $port                       = '5672'
  $ssl                        = false
  $ssl_cacert                 = 'UNSET'
  $ssl_cert                   = 'UNSET'
  $ssl_key                    = 'UNSET'
  $ssl_management_port        = '5671'
  $ssl_stomp_port             = '6164'
  $stomp_port                 = '6163'
  $wipe_db_on_cookie_change   = false
  $cluster_partition_handling = 'ignore'
  $environment_variables      = {}
  $config_variables           = {}
}
