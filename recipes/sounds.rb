# Cookbook Name:: asterisk
# Recipe:: sounds

# Install asterisk sounds

## Download digium sound files
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
## Download spanish sound files
node['asterisk']['server']['sounds_es_formats'].each do |format|
  files=["voipnovatos-core-sounds-es-#{format}-1.4.tar.gz", "voipnovatos-extra-sounds-es-#{format}-1.4.tar.gz"]
  files.each do |file_name|
    remote_file "#{Chef::Config[:file_cache_path]}/#{file_name}" do
      file="#{node['asterisk']['server']['sounds_es_url']}/#{file_name}"
      Chef::Log.info("Downloading #{file}")
      source file
      action :create_if_missing
      notifies :run, "bash[unpack-#{file_name}]"
    end
    sounds_dir="/var/lib/asterisk/sounds/es"
    bash "unpack-#{file_name}" do
      cwd Chef::Config[:file_cache_path]
      Chef::Log.info("Unpacking #{file_name}")
      action :nothing
      code <<-EOH
        rm -rf tmp && mkdir tmp && cd tmp
        tar xzf ../#{file_name}
        for d in dictate digits followme letters phonetic silence; do
          if [ -d $d ]; then
            # Fixing dir structure
            mv $d/es/* $d
            rmdir $d/es
            mv $d es
          fi
        done
        cp -a es/* #{sounds_dir}
      EOH
    end
  end
end
file_name="asterisk-voces-es-v1_2-moh-voipnovatos.tar.gz"
remote_file "#{Chef::Config[:file_cache_path]}/#{file_name}" do
  file="#{node['asterisk']['server']['sounds_es_url']}/#{file_name}"
  Chef::Log.info("Downloading #{file}")
  source file
  action :create_if_missing
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

