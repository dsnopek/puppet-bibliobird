
class bibliobird::nlp {
  Class['bibliobird'] -> Class['bibliobird::nlp']

  package {'python-pip':
    ensure => 'installed',
  }

  package {'PyYAML':
    ensure   => '3.09',
    provider => pip,
    require  => Package['python-pip'],
  }

  package {'simplejson':
    ensure   => '2.1.1',
    provider => pip,
    require  => Package['python-pip'],
  }

  # Buggy in Puppet 2.7 - fixed here: https://github.com/puppetlabs/puppet/pull/1256
  #package {'html5lib':
  #  ensure   => 'installed',
  #  provider => pip,
  #  source   => 'http://html5lib.googlecode.com/files/html5lib-0.90.zip',
  #  require  => Package['python-pip'],
  #}

  exec {'pip install html5lib':
    command => 'pip install http://html5lib.googlecode.com/files/html5lib-0.90.zip#egg=html5lib',
    unless  => "python -c 'import html5lib'",
    require => Package['python-pip'],
  }

  # Buggy in Puppet 2.7 - fixed here: https://github.com/puppetlabs/puppet/pull/1256
  #package {'nltk':
  #  ensure   => 'installed',
  #  provider => pip,
  #  source   => 'http://nltk.googlecode.com/files/nltk-2.0b9.zip',
  #  require  => Package['python-pip'],
  #}

  exec {'pip install nltk':
    command => 'pip install http://nltk.googlecode.com/files/nltk-2.0b9.zip#egg=nltk',
    unless  => "python -c 'import nltk'",
    require => Package['python-pip'],
  }

  # Install the 'punkt' data package
  exec {"python -c \"import nltk; nltk.download('punkt')\"":
    user    => $bibliobird::aegir_user,
    cwd     => $bibliobird::aegir_root,
    environment => [ "HOME=${bibliobird::aegir_root}" ],
    creates => "${bibliobird::aegir_root}/nltk_data/tokenizers/punkt",
    require => Exec['pip install nltk'],
  }
}

