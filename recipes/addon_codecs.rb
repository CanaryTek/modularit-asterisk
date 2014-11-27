# Cookbook Name:: asterisk
# Recipe:: addon_codecs
# Install additional codecs (g729 and g723)

# FIXME: Set this in attributes
base_url="http://asterisk.hosting.lv/bin"
asterisk_version="11"
codec_flavor="x86_64-core2-sse4"
ast_modules_dir="/usr/lib/asterisk/modules"

%w{g729 g723}.each do |codec|
remote_file "#{ast_modules_dir}/codec_#{codec}.so" do
    source "#{base_url}/codec_#{codec}-ast#{asterisk_version}0-gcc4-glibc-#{codec_flavor}.so"
    action :create_if_missing
    owner "asterisk"
    group "asterisk"
    mode 00755
  end
end

