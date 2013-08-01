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

include_recipe "git"

package "nodejs"

user node[:statsd][:user] do
  comment node[:statsd][:user]
  system true
  shell "/bin/false"
  action :create
end

git node[:statsd][:base_dir] do
  repository node[:statsd][:repo_url]
  reference node[:statsd][:branch]
  action :checkout
end

directory node[:statsd][:log_dir] do
  owner node[:statsd][:user]
  group node[:statsd][:group]
  mode 0755
  action :create
end

directory node[:statsd][:conf_dir] do
  owner node[:statsd][:user]
  group node[:statsd][:group]
  mode 0755
  action :create
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

template "/etc/init/statsd.conf" do
  source "upstart.conf.erb"
  mode 0644
  variables(
    :user => node[:statsd][:user],
    :basedir => node[:statsd][:base_dir],
    :logdir => node[:statsd][:log_dir],
    :confdir => node[:statsd][:conf_dir]
  )
end

service "statsd" do
  provider Chef::Provider::Service::Upstart
  supports :start => true, :status => true, :restart => true
  action [ :enable, :start ]
end
