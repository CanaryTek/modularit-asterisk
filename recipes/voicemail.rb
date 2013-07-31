# Cookbook Name:: modularit-asterisk
# Recipe::  voicemail 

# Include base recipe
include_recipe 'modularit-asterisk'

# Basic config files
["extensions.conf","logger.conf","modules.conf","sip.conf","voicemail.conf"].each do |file|
  template "/etc/asterisk/#{file}" do
    source "#{file}.erb"
    cookbook "modularit-asterisk"
    owner "asterisk"
    group "asterisk"
    mode 00644
    action :create
  end
end

