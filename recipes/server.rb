#
# Cookbook Name:: rsyslog
# Recipe:: server
#
# Copyright 2009-2014, Chef Software, Inc.
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

# Manually set this attribute
node.set['rsyslog']['server'] = true

include_recipe 'rsyslog::default'

directory node['rsyslog']['log_dir'] do
  owner    node['rsyslog']['user']
  group    node['rsyslog']['group']
  mode     '0755'
  recursive true
end

if node['rsyslog']['server_per_host']
  template "#{node['rsyslog']['config_prefix']}/rsyslog.d/35-server-per-host.conf" do
    source   '35-server-per-host.conf.erb'
    owner    'root'
    group    'root'
    mode     '0644'
    notifies :restart, "service[#{node['rsyslog']['service_name']}]"
  end
end

node['rsyslog']['server_program_names'].each do |program|
  template "#{node['rsyslog']['config_prefix']}/rsyslog.d/#{program}.conf" do
    source    'program.conf.erb'
    owner     'root'
    group     'root'
    mode      '0644'
    variables program: program
    notifies :restart, "service[#{node['rsyslog']['service_name']}]"
  end
end

file "#{node['rsyslog']['config_prefix']}/rsyslog.d/remote.conf" do
  action   :delete
  notifies :restart, "service[#{node['rsyslog']['service_name']}]"
  only_if  { ::File.exist?("#{node['rsyslog']['config_prefix']}/rsyslog.d/remote.conf") }
end
