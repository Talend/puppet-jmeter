define jmeter::config_property_file (
  $filename,
  $change_set
  )
{
  augeas { $filename:
    lens    => 'Properties.lns',
    incl    => "/usr/share/jmeter/bin/${filename}",
    context => "/files/usr/share/jmeter/bin/${filename}",
    changes => $change_set,
  }

}
