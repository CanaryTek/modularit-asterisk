# Cookbook Name:: asterisk
# Recipe:: security

# Packages
%w{crudini fail2ban}.each do |pkg|
  package pkg do
    action :install
  end
end

# Enable Asterisk Jail
execute "asterisk-jail-anable" do
  command "crudini --set /etc/fail2ban/jail.conf asterisk enabled yes"
  not_if "crudini --get /etc/fail2ban/jail.conf asterisk enabled | grep -q yes"
  notifies :reload, "service[fail2ban]"
end

service "fail2ban" do
  action [ :start, :enable ]
end
