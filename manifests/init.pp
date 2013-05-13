
class bibliobird ($production = false, $drupal6_platform = 'bibliobird-drupal6', $drupal7_platform = 'bibliobird')
  inherits mvpcreator::webserver::aegir_config
{

  # TODO: Replace with something like the code here: http://projects.puppetlabs.com/projects/1/wiki/Debian_Apache2_Recipe_Patterns
  #apache::mod {'headers': }

  # Ensure that all of aegir happens first!
  Class['mvpcreator::webserver'] -> Class['bibliobird']

  if ! $::aegir_root { $aegir_root = '/var/aegir' }
  else               { $aegir_root = $::aegir_root }
  if ! $::aegir_user { $aegir_user = 'aegir' }
  else               { $aegir_user = $::aegir_user }

  if $production {
    $branch = 'production'
  }
  else {
    $branch = 'master'
  }
  
  package {'git':
    ensure => present,
  }

  Bibliobird::Git {
    user  => $aegir_user,
  }

  Exec {
    path        => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    user        => $aegir_user,
    group       => $aegir_user,
    environment => "HOME=${aegir_root}",
  }

  if $drupal6_platform {
    #
    # Drupal 6 version of Bibliobird
    #

    file {"${aegir_root}/prj":
      ensure => directory,
      owner  => $aegir_user,
      group  => $aegir_user,
      mode   => '0755',
    }

    bibliobird::git {"${aegir_root}/prj/bbcom":
      source => 'git://github.com/dsnopek/bbcom.git',
      branch => $branch,
    }

    bibliobird::git {"${aegir_root}/prj/lingwo-old":
      source => 'git://github.com/dsnopek/lingwo-old.git',
      branch => $branch,
    }

    file {"${aegir_root}/prj/bbcom/drupal/sites/all/modules/lingwo-old":
      ensure  => link,
      target  => "${aegir_root}/prj/lingwo-old",
      owner   => $aegir_user,
      group   => $aegir_user,
      require => [ Bibliobird::Git["${aegir_root}/prj/bbcom"],
                   Bibliobird::Git["${aegir_root}/prj/lingwo-old"] ],
    }

    bibliobird::git {"${aegir_root}/prj/lingwo":
      source => 'git://github.com/dsnopek/lingwo.git',
      branch => $branch,
    }

    file {"${aegir_root}/prj/bbcom/drupal/sites/all/modules/lingwo":
      ensure  => link,
      target  => "${aegir_root}/prj/lingwo",
      owner   => $aegir_user,
      group   => $aegir_user,
      require => [ Bibliobird::Git["${aegir_root}/prj/bbcom"],
                   Bibliobird::Git["${aegir_root}/prj/lingwo"] ],
    }

    file {"${aegir_root}/platforms/${drupal6_platform}-${branch}":
      ensure  => link,
      target  => "${aegir_root}/prj/bbcom/drupal",
      owner   => $aegir_user,
      group   => $aegir_user,
      notify  => Aegir::Platform['bibliobird-drupal6-master'],
      require => [ Bibliobird::Git["${aegir_root}/prj/bbcom"],
                   File["${aegir_root}/prj/bbcom/drupal/sites/all/modules/lingwo-old"],
                   File["${aegir_root}/prj/bbcom/drupal/sites/all/modules/lingwo"] ],
    }

    aegir::platform {"${drupal6_platform}-${branch}":
      makefile => undef,
    }
  }

  if $drupal7_platform {
    #
    # Drupal 7 version of Bibliobird
    #

    # Using Drush makefile
    aegir::platform {"${drupal7_platform}-${branch}":
      makefile      => 'https://raw.github.com/dsnopek/bibliobird/master/build-bibliobird.make',
      working_copy  => true,
      build_timeout => '600',
    }
  }


}

