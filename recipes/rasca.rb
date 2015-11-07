# Cookbook Name:: asterisk
# Recipe:: rasca

# Object files for rasca alerts

# (Only if rasca is being used)
if node.attribute?("rasca") then

rasca_object "SecPkgChk-asterisk" do
  check "SecPkgChk"
  format "ruby"
  content '{ 
    "asterisk" => { :ports => [ "UDP/5060", "TCP/5036", "UDP/4569", "UDP/10000:20000" ] },
  }'
end

end
