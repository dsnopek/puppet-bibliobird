
define bibliobird::git ($source, $path = $name, $branch = 'master', $user = 'UNSET') {
  if $user != 'UNSET' {
    Exec {
      user => $user,
    }
  }

  exec {"git clone --recursive --branch ${branch} ${source} ${path}":
    creates => $path,
    require => Package['git'],
  }
}

