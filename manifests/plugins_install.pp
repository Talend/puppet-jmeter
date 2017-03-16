define jmeter::plugins_install (
  $plugins_version,
  $plugins_set = $title,
  $base_download_url = 'http://jmeter-plugins.org/downloads/file/'
  )
{
  $plugins_file_base = "JMeterPlugins-${plugins_set}-${plugins_version}"

  exec { "download-jmeter-plugins-${plugins_set}":
    command => "wget -P /root ${base_download_url}/${plugins_file_base}.zip",
    creates => "/root/${plugins_file_base}.zip"
  }

  exec { "install-jmeter-plugins-${plugins_set}":
    command => "unzip -q -o -d JMeterPlugins-${plugins_set} ${plugins_file_base}.zip && cp -r JMeterPlugins-${plugins_set}/lib/* /usr/share/jmeter/lib/",
    cwd     => '/root',
    creates => "/usr/share/jmeter/lib/ext/JMeterPlugins-${plugins_set}.jar",
    require => Exec["download-jmeter-plugins-${plugins_set}"],
  }
}

define jmeter::jdbc_plugins_install (
  $plugins_set = $title,
  $base_download_url = 'http://jmeter-plugins.org/files/packages/'
  )
{
  $plugins_file_base = "jpgc-${title}"

  exec { "download-jdbc-plugins-${plugins_set}":
    command => "wget -P /root ${base_download_url}/${plugins_file_base}.zip",
    creates => "/root/${plugins_file_base}.zip"
  }

  exec { "install-jpgc-plugins-${plugins_set}":
    command => "unzip -q -o -d ${plugins_file_base} ${plugins_file_base}.zip && cp -r ${plugins_file_base}/lib/* /usr/share/jmeter/lib/",
    cwd     => '/root',
    unless      => "/bin/ls /usr/share/jmeter/lib/ext/jmeter-plugins*${plugins_set}.jar",
    require => Exec["download-jdbc-plugins-${plugins_set}"],
  }
}
