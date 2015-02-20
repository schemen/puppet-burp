# Define: burp::clientconf
# Parameters:
# arguments
#

define burp::clientconf (
  $includes = undef,
  $excludes = undef,
  $options  = undef,
  $password = undef,
  ) {

  file { "/etc/burp/clientconfdir/${title}":
    mode    => "600",
    content => template('burp/clientconf-win.erb'),
    require => File['/etc/burp/clientconfdir'],
  }

}


