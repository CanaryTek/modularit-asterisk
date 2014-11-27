# Cookbook Name:: asterisk
# Recipe:: install_from_source

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

## Download sound files
node['asterisk']['server']['sounds_formats'].each do |format|
  node['asterisk']['server']['sounds_langs'].each do |lang|
    # Download core sounds in all configured languages
    file_name="asterisk-core-sounds-#{lang}-#{format}-current.tar.gz"
    remote_file "#{Chef::Config[:file_cache_path]}/#{file_name}" do
      file="#{node['asterisk']['server']['sounds_url']}/#{file_name}"
      Chef::Log.info("Downloading #{file}")
      source file
      action :create_if_missing
    end
  end
  # Download extra sounds only available in english
  file_name="asterisk-extra-sounds-en-#{format}-current.tar.gz"
  remote_file "#{Chef::Config[:file_cache_path]}/#{file_name}" do
    file="#{node['asterisk']['server']['sounds_url']}/#{file_name}"
    Chef::Log.info("Downloading #{file}")
    source file
    action :create_if_missing
  end
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

# Unpack core sound files
node['asterisk']['server']['sounds_langs'].each do |lang|
  sounds_dir="/var/lib/asterisk/sounds/#{lang}"
  directory sounds_dir do
    action :create
    owner "asterisk"
    group "asterisk"
  end
  node['asterisk']['server']['sounds_formats'].each do |format|
    file="#{Chef::Config[:file_cache_path]}/asterisk-core-sounds-#{lang}-#{format}-current.tar.gz"
    Chef::Log.info("Unpacking #{file}")
    execute "unpack-core-sounds-#{format}" do
      cwd sounds_dir
      command "tar xzf #{file} && chown -R asterisk.asterisk #{sounds_dir}"
      creates "#{sounds_dir}/agent-alreadyon.#{format}"
    end
  end
end

# Unpack extra sound files. Only available in "en" language
sounds_dir="/var/lib/asterisk/sounds/en"
node['asterisk']['server']['sounds_formats'].each do |format|
  file="#{Chef::Config[:file_cache_path]}/asterisk-extra-sounds-en-#{format}-current.tar.gz"
  Chef::Log.info("Unpacking #{file}")
  execute "unpack-extra-sounds-#{format}" do
    cwd sounds_dir
    command "tar xzf #{file} && chown -R asterisk.asterisk #{sounds_dir}"
    creates "#{sounds_dir}/OfficeSpace.#{format}"
  end
end


