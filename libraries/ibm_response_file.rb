
#
# Cookbook Name:: ibm-installmgr
# Resource:: ibm_response_file
#
# Copyright (C) 2015-2018 J Sainsburys
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

module InstallMgrCookbook
  class IbmResponseFile < Chef::Resource
    resource_name :ibm_response_file

    property :response_file, String, name_property: true
    property :group, String, default: 'ibm-im'
    property :owner, String, default: 'ibm-im'
    property :template_source, [String, nil], default: nil
    property :cookbook, [String, nil], default: nil
    property :variables, [Hash, nil], default: nil

    action :create do
      config_dir = ::File.dirname(new_resource.response_file)

      directory config_dir do
        owner new_resource.owner
        group new_resource.group
        mode '0750'
        recursive true
        action :create
      end

      template "response_file :create #{new_resource.response_file}" do
        path new_resource.response_file
        owner new_resource.owner
        group new_resource.group
        mode '0750'
        source new_resource.template_source
        cookbook new_resource.cookbook
        variables new_resource.variables
        action :create
      end
    end
  end
end
