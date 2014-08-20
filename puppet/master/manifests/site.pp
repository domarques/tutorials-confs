node default {

  service { 'ntp':
    name      => ntp,
    ensure    => running,
    enable    => true,
  }

}
node 'puppet.domarques.com.br' {

  # PuppetDB
  class { 'puppetdb':
      report_ttl        => '7d'
  }

  class { 'puppetdb::master::config':
      manage_report_processor => true,
      enable_reports          => true
  }

  # PuppetDashboard
  class { 'python':
      virtualenv => true,
      pip        => true
  }
  class { 'apache': }
  class { 'apache::mod::wsgi': }
  class { 'puppetboard': }
  class { 'puppetboard::apache::vhost':
      vhost_name => 'puppet.domarques.com.br',
      port       => '8888'
  }

}
node 'agent.domarques.com.br' inherits default {

  $pacotes = [ 'ntp', 'vim', 'sudo', 'ntpdate', 'screen', 'less', 'unzip', 'bzip2', 'multitail', 'htop', 'curl', ]
  package { $pacotes: ensure => "installed" }

  user { "domarques":
    ensure     => "present",
    managehome => true,
  }

  file { 'hostname' :
    path   => '/etc/hostname',
    source => ['puppet:///extra_files/agent.domarques.com.br/hostname'],
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 644,
  }

  file { 'puppet.md' :
    path   => '/home/domarques/puppet.md',
    content => "Este sistema é controlado pelo puppet!",
    ensure => present,
    owner  => domarques,
    group  => domarques,
    mode   => 644,
  }

}
