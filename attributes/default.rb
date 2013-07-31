# Author:: Kuko Armas
# Cookbook Name:: modularit-asterisk
# Attribute:: default



## Building config. You should not need to change anything after this line
default['asterisk']['server']['libpri_url'] = "http://downloads.asterisk.org/pub/telephony/libpri/"
default['asterisk']['server']['libpri_version'] = "1.4.14"
default['asterisk']['server']['libpri_file'] = "libpri-#{node['asterisk']['server']['libpri_version']}.tar.gz"
default['asterisk']['server']['asterisk_url'] = "http://downloads.asterisk.org/pub/telephony/asterisk/"
default['asterisk']['server']['asterisk_version'] = "11.5.0"
default['asterisk']['server']['asterisk_file'] = "asterisk-#{node['asterisk']['server']['asterisk_version']}.tar.gz"
default['asterisk']['server']['dahdi_url'] = "http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/"
default['asterisk']['server']['dahdi_version'] = "2.7.0"
default['asterisk']['server']['dahdi_file'] = "dahdi-linux-complete-#{node['asterisk']['server']['dahdi_version']}+#{node['asterisk']['server']['dahdi_version']}.tar.gz"

case node['platform_family']
when 'debian'
  default['asterisk']['build_deps'] = 'PLEASE_DEFINE'
when 'rhel','fedora'
  default['asterisk']['build_deps'] = "gcc gcc-c++ make ncurses-devel newt-devel libxml2-devel openssl-devel sqlite-devel libuuid-devel"
else
  default['asterisk']['build_deps'] = 'PLEASE_DEFINE'
end

