
#
# Cookbook Name:: ibm-installmgr
# Resource:: ibm_package_response
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
  class IbmPackageResponse < Chef::Resource
    require_relative 'helpers'
    include InstallMgrHelpers

    resource_name :ibm_package_response
    property :package, String, name_property: true
    property :response_file, String, required: true
    property :imcl_dir, String, default: '/opt/IBM/InstallationManager/eclipse/tools'
    property :log_dir, String, default: '/var/IBM/InstallationManager/logs'
    property :pkg_group, String, default: 'ibm'
    property :pkg_owner, String, default: 'ibm'
    property :access_rights, String, default: 'nonAdmin', regex: /^(nonAdmin|admin|group)$/

    provides :ibm_package_response if defined?(provides)

    action :install do
      unless package_installed?(new_resource.package, new_resource.imcl_dir)
        directory new_resource.log_dir do
          owner new_resource.pkg_owner
          group new_resource.pkg_group
          mode '0755'
          recursive true
          action :create
        end

        date = Time.now.strftime('%d%b%Y-%H%M')
        filename = ::File.basename(new_resource.response_file, '.xml')
        logfile = "#{filename}-#{date}.log"
        imcl_wrapper(
          new_resource.imcl_dir,
          "./imcl -accessRights \"#{new_resource.access_rights}\" input \"#{new_resource.response_file}\"",
          "-log \"#{new_resource.log_dir}/#{logfile}\" -acceptLicense"
        )
      end
    end

    # need to wrap helper methods in class_eval
    # so they are available in the action.
    action_class.class_eval do
      def imcl_wrapper(_imcl_directory, cmd, options)
        command = "#{cmd} #{options}"

        execute "imcl input #{new_resource.response_file}" do
          cwd _imcl_directory
          command command
          action :run
        end
      end
    end
  end
end
