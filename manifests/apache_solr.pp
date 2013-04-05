
class bibliobird::apache_solr {
  Class['bibliobird'] -> Class['bibliobird::apache_solr']

  package {'openjdk-6-jdk':
    ensure => 'installed',
  }

  package {'solr-jetty':
    ensure  => 'installed',
    require => Package['openjdk-6-jdk'],
  }

  include bibliobird::apache_solr_config

  service {'jetty':
    ensure    => running,
    # Restart jetty on config changes
    subscribe => Class['bibliobird::apache_solr_config'],
  }
}

class bibliobird::apache_solr_config {
  file {'/etc/default/jetty':
    ensure  => present,
    source  => "puppet:///modules/bibliobird/solr/jetty",
    require => Package['solr-jetty'],
  }

  file {'/usr/share/solr':
    ensure => directory,
    owner  => 'jetty',
    group  => 'jetty',
    require => Package['solr-jetty'],
  }

  file {'/usr/share/solr/lib':
    ensure => directory,
    owner  => 'jetty',
    group  => 'jetty',
    require => Package['solr-jetty'],
  }

  file {'/usr/share/solr/solr.xml':
    ensure => present,
    owner  => 'jetty',
    group  => 'jetty',
    mode   => '0640',
    source  => "puppet:///modules/bibliobird/solr/solr.xml",
    require => Package['solr-jetty'],
    # This file gets updated everytime a new core is added, so, we only want to
    # create it if it's absent -- NOT overwrite the file if it differs from the
    # original.
    replace => "no",
  }

  file {'/usr/share/solr/lib/dhc-solr-plugins.jar':
    ensure => present,
    owner  => 'jetty',
    group  => 'jetty',
    source  => "puppet:///modules/bibliobird/solr/dhc-solr-plugins.jar",
    require => Package['solr-jetty'],
  }

  file {'/usr/share/solr/cores':
    ensure => directory,
    owner  => 'jetty',
    group  => 'jetty',
    require => Package['solr-jetty'],
  }

  file {'/etc/solr/conf/schema.xml':
    ensure  => present,
    source  => "puppet:///modules/bibliobird/solr/schema.xml",
    require => Package['solr-jetty'],
  }

  file {'/etc/solr/conf/solrconfig.xml':
    ensure  => present,
    source  => "puppet:///modules/bibliobird/solr/solrconfig.xml",
    require => Package['solr-jetty'],
  }
}

