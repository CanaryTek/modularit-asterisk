#
# Cookbook Name:: asterisk
# Recipe:: default
#
# Copyright 2013, CanaryTek
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform']
when "debian", "ubuntu"
  include_recipe 'apt'
when "centos","redhat"
  include_recipe 'yum'
  include_recipe "yum::epel"
end

# Install build dependencies
packages = node['asterisk']['build_deps'].split
packages.each do |pkg|
  package pkg do
    action :install
  end
end

case node['platform']
when "centos","redhat"
  bash "Workaround for http://tickets.opscode.com/browse/COOK-1210" do 
    code <<-EOH
      echo 0 > /selinux/enforce
    EOH
  end
end

version = node['asterisk']['server']['version']

# Download libpri source file
remote_file "#{Chef::Config[:file_cache_path]}/#{node['asterisk']['server']['libpri_file']}" do
  file="#{node['asterisk']['server']['libpri_url']}/#{node['asterisk']['server']['libpri_file']}"
  Chef::Log.info("Downloading #{file}")
  source file
  action :create_if_missing
end

# Download DAHDI source file
remote_file "#{Chef::Config[:file_cache_path]}/#{node['asterisk']['server']['dahdi_file']}" do
  file="#{node['asterisk']['server']['dahdi_url']}/#{node['asterisk']['server']['dahdi_file']}"
  Chef::Log.info("Downloading #{file}")
  source file
  action :create_if_missing
end

# Download Asterisk source file
remote_file "#{Chef::Config[:file_cache_path]}/#{node['asterisk']['server']['asterisk_file']}" do
  file="#{node['asterisk']['server']['asterisk_url']}/#{node['asterisk']['server']['asterisk_file']}"
  Chef::Log.info("Downloading #{file}")
  source file
  action :create_if_missing
end

# Compile and install dahdi
bash "compile-dahdi" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    yum install -y kernel-devel-`uname -r`
    tar zxvf #{node['asterisk']['server']['dahdi_file']}
    cd dahdi-*
    make
    make install
    make config
  EOH
  creates "/usr/sbin/dahdi_cfg"
end


# Compile and install libpri
bash "compile-libpri" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf #{node['asterisk']['server']['libpri_file']}
    cd libpri-*
    make
    make install
  EOH
  creates "/usr/lib/libpri.so.1.4"
end

user "asterisk" do
  home "/var/lib/asterisk"
  comment "Asterisk"
  supports :manage_home => true
  shell "/sbin/nologin"
end

# Compile and install asterisk
bash "compile-asterisk" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf #{node['asterisk']['server']['asterisk_file']}
    cd asterisk-*
    ./configure
    make
    make install
    make config
    # Create config variables
    echo "# Entries for modularit-asterisk recipe" >>/etc/sysconfig/asterisk"
    echo "AST_USER=asterisk" >>/etc/sysconfig/asterisk"
    echo "AST_GROUP=asterisk" >>/etc/sysconfig/asterisk"
    echo "COLOR=no" >>/etc/sysconfig/asterisk"
    # Change owner
    chown -R asterisk.asterisk /var/log/asterisk
    chown -R asterisk.asterisk /var/spool/asterisk
    ldconfig -v
  EOH
  creates "/usr/sbin/asterisk"
end


