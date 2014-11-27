# Cookbook Name:: asterisk
# Recipe:: default

# Include base recipe
include_recipe 'modularit-asterisk::install_from_source'
include_recipe 'modularit-asterisk::addon_codecs'
include_recipe 'modularit-asterisk::security'


