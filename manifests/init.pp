# == Class: burp
#
# Full description of class burp here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { burp:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#

#https://launchpad.net/~bas-dikkenberg/+archive/burp-stable

class burp (
# general settings
  $mode                = server,
  
# server settings for /etc/burp-server.conf 
  $directory           = "/mnt/backup/burpdata",
  $max_children        = "25",
  $max_status_children = "25",
  $keep                = "60",
  $waittime            = "20",
  $starttime           = "Mon,Tue,Wed,Thu,Fri,Sat,Sun,00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23",
 
# server settings for client config files in /etc/clientconfdir
  $clientconf_hash     = {'NNMS00' => { $clientname        = $name,
                                        $includes          = "C:/",
                                        $excludes          = "D:/$RECYCLE.BIN/",
                                        $options           = undef,
                                        $password          = undef,
                                      }
                         }
 # client settings
  $installpackage = true,
  ) {
  
  case $::mode {
    server: {
      # Create file burp-server.conf
      file { '/etc/burp/burp-server.conf':
        ensure  => present,
        mode    => '600',
        content => template("burp/burp-server.conf.erb"),
        require => Package['burp']
      }

      # Start service
      service { 'burp':
        ensure  => 'running',
        require => File['/etc/burp/burp-server.conf'] 
      }

      # Fill /etc/burp/clientconfdir
      create_resources('burp::clientconf', $clientconf_hash)
    }

    client: {
      if $installpackage {
      class { 'burp::installpackage' }
      }
    }
  }

}