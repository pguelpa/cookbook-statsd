#
# Cookbook Name:: statsd
# Recipe:: default
#
# Copyright 2011, Blank Pad Development
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

include_recipe "build-essential"
include_recipe "git"

package "nodejs"

user node[:statsd][:user] do
  comment node[:statsd][:user]
  system true
  shell "/bin/false"
  action :create
end

git "/tmp/statsd" do
  repository node[:statsd][:repo_url]
  reference node[:statsd][:branch]
  action :checkout
end

execute "checkout statsd" do
  command "git clone git@github.com:etsy/statsd.git"
  creates "/tmp/statsd"
  cwd "/tmp"
end

package "debhelper"

execute "build debian package" do
  command "dpkg-buildpackage -us -uc"
  creates "/tmp/statsd_*_all.deb"
  cwd "/tmp/statsd"
end

dpkg_package "statsd" do
  action :install
  source "/tmp/statsd_*_all.deb"
end

template "#{node[:statsd][:conf_dir]}/localConfig.js" do
  source "localConfig.js.erb"
  mode 0644
  variables(
    :port => node[:statsd][:port],
    :graphitePort => node[:statsd][:graphite_port],
    :graphiteHost => node[:statsd][:graphite_host]
  )

  notifies :restart, "service[statsd]"
end

template "/usr/share/statsd/scripts/start" do
  source "upstart.start.erb"
  mode 0755
  variables(
    :logdir => node[:statsd][:log_dir],
    :confdir => node[:statsd][:conf_dir]
  )
end

template "/etc/init/statsd.conf" do
  source "upstart.conf.erb"
  mode 0644
  variables(
    :user => node[:statsd][:user]
  )
end

directory node[:statsd][:log_dir] do
  owner node[:statsd][:user]
  group node[:statsd][:group]
  mode 0755
  action :create
end

service "statsd" do
  action [ :enable, :start ]
end
