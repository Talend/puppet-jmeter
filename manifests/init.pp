# == Class: jmeter
#
# This class installs the latest stable version of JMeter.
#
# === Examples
#
#   class { 'jmeter': }
#
class jmeter (
  $jmeter_version         = '2.13',
  $jmeter_plugins_install = false,
  $jmeter_plugins_version = '1.2.1',
  $jmeter_plugins_set     = ['Standard'],
  $jpgc_plugins_set       = [],
  $jpgc_plugin_url        = 'http://jmeter-plugins.org/files/packages/',
  $download_url           = 'http://archive.apache.org/dist/jmeter/binaries/',
  $plugin_url             = 'http://jmeter-plugins.org/downloads/file/',
  $java_version           = $::jmeter::params::java_version,
  $user_property_config   = [],
  $jmeter_property_config = [],
) inherits ::jmeter::params {

  validate_re($download_url, '^((https?|ftps?):\/\/)([\da-z\.-]+)\.?([\da-z\.]{2,6})([\/\w \.\:-]*)*\/?$')
  validate_re($plugin_url, '^((https?|ftps?):\/\/)([\da-z\.-]+)\.?([\da-z\.]{2,6})([\/\w \.\:-]*)*\/?$')

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  $jdk_pkg = $::jmeter::params::jdk_pkg

  #ensure_resource('package', [$jdk_pkg, 'unzip', 'wget'], {'ensure' => 'present'})

  exec { 'download-jmeter':
    command => "wget -P /root ${download_url}/apache-jmeter-${jmeter_version}.tgz",
    creates => "/root/apache-jmeter-${jmeter_version}.tgz"
  }

  exec { 'install-jmeter':
    command => "tar xzf /root/apache-jmeter-${jmeter_version}.tgz && mv apache-jmeter-${jmeter_version} jmeter",
    cwd     => '/usr/share',
    creates => '/usr/share/jmeter',
    require => Exec['download-jmeter'],
  }

  if $jmeter_plugins_install == true {
    jmeter::plugins_install { $jmeter_plugins_set:
      plugins_version   => $jmeter_plugins_version,
      base_download_url => $plugin_url,
      require           => [Package['wget'], Package['unzip'], Exec['install-jmeter']],
    }
  }

  if $jpgc_plugins_set != [] {
    jmeter::jdbc_plugins_install { $jpgc_plugins_set:
      base_download_url => $jpgc_plugin_url,
      require           => [Package['wget'], Package['unzip'], Exec['install-jmeter']],
    }
  }

  if $user_property_config != [] {
    jmeter::config_property_file { 'user.properties':
      filename   => 'user.properties',
      change_set => $user_property_config,
      require    => Exec['install-jmeter'],
    }
  }

  if $jmeter_property_config != [] {
    jmeter::config_property_file { 'jmeter.properties':
      filename   => 'jmeter.properties',
      change_set => $jmeter_property_config,
      require    => Exec['install-jmeter'],
    }
  }
}
