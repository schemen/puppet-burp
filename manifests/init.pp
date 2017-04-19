# == Class: burp
#
#
# === Authors
#
# Author Name rudi.broekhuizen@naturalis.nl
#

class burp (
# general settings
  $mode             = 'server',
  $ssl_key_password = 'password',

# client: settings for /etc/burp/burp.conf
  $server             = '127.0.0.1',
  $client_password    = 'password',
  $cname              = $::fqdn,
  $server_can_restore = '1',
  $client_user        = 'root',  # set sensu for server monitoring
  $client_group       = 'root',  # set sensu for server monitoring
  
# client: create client config files in /etc/clientconfdir for Linux clients
  $includes               = '/home',
  $excludes               = '/tmp',
  $options                = '',
  $password               = 'password',
  $cron                   = true,
  $backup_script_pre      = '',

# server: autoupdate (Windows 64 bit only), put file in files 
  $autoupgrade            = true,
  $autoupgradeversion     = '2.0.54',
  $autoupgradefilename    = 'burp-win64-installer-2.0.54.exe',

# server: settings for /etc/burp-server.conf
  $directory             = '/mnt/backup/burpdata',
  $max_children          = '25',
  $max_status_children   = '25',
  $keep                  = '70',
  $waittime              = '20h',
  $starttime             = 'Mon,Tue,Wed,Thu,Fri,Sat,Sun,00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23',
  $common_clientconfig   = ['working_dir_recovery_method=resume'],
  $backup_stats_logstash = true,

# server: create client config files in /etc/clientconfdir for Windows clients
  $clientconf           = false,  
  $clientconf_hash      = { 'servername-01.domain' => { password => 'password'},
                            'servername-02.domain' => { password => 'password'}
                          },

# server: create sensu checks for server based backup monitoring, warning and critical hours adjustable per client
  $chkbackup            = false,
  $chkbackup_hash       = { 'testclient1' => { 'chkwarninghours' => '24', 'chkcriticalhours' => '48' },
                            'testclient2' => { 'chkwarninghours' => '24', 'chkcriticalhours' => '48' }
                          },
) {

  if $burp::mode == 'server' {
    file {['/etc/burp']:
      ensure                  => 'directory',
      mode                    => '0640',
      owner                   => 'root',
      group                   => $client_group,
      recurse                 => true,
    }

    file {['/etc/burp/timer_script']:
      ensure                  => 'file',
      mode                    => '0770',
      owner                   => 'root',
      group                   => $client_group,
      require                 => Class['burp::server']
    }
    include burp::serverpackage
    if $burp::chkbackup == true {
        create_resources('burp::chkbackup', $burp::chkbackup_hash)
    }
    class {'burp::server':
      clientconf_hash       => $burp::clientconf_hash,
      common_clientconfig   => $burp::common_clientconfig,
    }
    if $burp::autoupdate == true {
      exec {'autoupgradedir':
        command           => "mkdir -p /etc/burp/autoupgrade/server/win64/${burp::autoupgradeversion}",
        path              => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
        unless            => "/usr/bin/test -d /etc/burp/autoupgrade/server/win64/${burp::autoupgradeversion}",
        require           => Class['burp::server']
      }
      file { "/etc/burp/autoupgrade/server/win64/script":
        ensure            => present,
        source            => 'puppet:///modules/burp/script',
        owner             => 'root',
        group             => 'root',
        mode              => '0644',
        require           => Exec['autoupgradedir']
      }
      file { "/etc/burp/autoupgrade/server/win64/${burp::autoupgradeversion}/package":
        ensure            => present,
        source            => "puppet:///modules/burp/${burp::autoupgradefilename}",
        owner             => 'root',
        group             => 'root',
        mode              => '0644',
        require           => Exec['autoupgradedir']
      }
    }
  } elsif $burp::mode == 'client' {
      include burp::clientpackage
      class {'burp::client':
        includes        => $burp::includes,
        excludes        => $burp::excludes,
        options         => $burp::options,
        password        => $burp::password,
        client_password => $burp::client_password,
        cname           => $burp::cname,
        cron            => $burp::cron,
      }

    } else {
        fail('unknown mode')
  }

}