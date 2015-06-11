#install nginx
package { "nginx":
    ensure => installed
}
# make sure nginx is running
service { "nginx":
    require => Package["nginx"],
    ensure => running,
    enable => true
}
#disable default nginx site

file { "/etc/nginx/sites-enabled/default":
    require => Package["nginx"],
    ensure  => absent,
    notify  => Service["nginx"]
}

file { "/var/www":
    ensure => "directory"
}
file { "/var/www/index.html":
    require => File["/var/www"],
    ensure => "file",
    content => "<!DOCTYPE html>
        <html><body>
        Hello, world.
        "
}

# create a puppet demo site vhost
file { "/etc/nginx/sites-available/puppet-demo":
    require => [
        Package["nginx"],
        File["/var/www"]
    ],
    ensure => "file",
    content => 
        "server {
            listen 80 default_server;
            server_name _;
            location / { root /var/www; }
        }",
    notify => Service["nginx"]
}

exec { "link_nginx_site":
    command => "ln -s /etc/nginx/sites-available/puppet-demo /etc/nginx/sites-enabled/puppet-demo",
    path    => "/usr/local/bin/:/bin/",
	notify => Service["nginx"]
}