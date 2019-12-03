# == Class: ipmi
#
class ipmi (
  Enum['running','stopped'] $service_ensure         = 'running',
  Enum['running','stopped'] $ipmievd_service_ensure = 'stopped',
  Boolean                   $watchdog               = false,
  Hash                      $snmps                  = {},
  Hash                      $users                  = {},
  Hash                      $networks               = {},
) inherits ipmi::params {

  $enable_ipmi = $service_ensure ? {
    'running' => true,
    'stopped' => false,
  }

  $enable_ipmievd = $ipmievd_service_ensure ? {
    'running' => true,
    'stopped' => false,
  }

  class { 'ipmi::install': } ~>
  class { 'ipmi::config':  } ~>
  class { '::ipmi::service::ipmi':
    ensure            => $service_ensure,
    enable            => $enable_ipmi,
    ipmi_service_name => $ipmi::params::ipmi_service_name,
  } ~>
  class { '::ipmi::service::ipmievd':
    ensure => $ipmievd_service_ensure,
    enable => $enable_ipmievd,
  }


  if $snmps {
    create_resources('ipmi::snmp', $snmps)
  }

  if $users {
    create_resources('ipmi::user', $users)
  }

  if $networks {
    create_resources('ipmi::network', $networks)
  }
}
