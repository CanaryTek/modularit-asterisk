# Cookbook Name:: modularit-asterisk
# Recipe::  voicemail 

# Include base recipe
include_recipe 'modularit-asterisk::default'

# Basic config files
["extensions.conf","logger.conf","modules.conf","sip.conf"].each do |file|
  template "/etc/asterisk/#{file}" do
    source "#{file}.erb"
    cookbook "modularit-asterisk"
    owner "asterisk"
    group "asterisk"
    mode 00644
    if node['asterisk']['voicemail']['manage_config']
      action :create
    else
      action :create_if_missing
    end
  end
end

# load Asterisk voicemail definitions from :asterisk_voicemail data bag
begin
  voicemails = search(:asterisk_voicemails, '*:*')
rescue Net::HTTPServerException
  Chef::Log.info("Could not search for asterisk_voicemails data bag items, skipping dynamically generated voicemails")
end
# Voicemail
template "/etc/asterisk/voicemail.conf" do
  source "voicemail.conf.erb"
  cookbook "modularit-asterisk"
  owner "asterisk"
  group "asterisk"
  mode 00644
  variables( 
    :asterisk_voicemails => voicemails
  )
end

