
#
# Cookbook Name:: ibm-installmgr
# Resource:: ibm_package
#
# Copyright (C) 2015 J Sainsburys
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
require_relative 'ibm_package'

module InstallMgrCookbook
  class IbmFixPack < IbmPackage
    require_relative 'helpers'
    include InstallMgrHelpers

    resource_name :ibm_fixpack

    action :install do
      unless package_installed?(package, imcl_dir, true)

        user service_user do
          comment 'ibm installation mgr service account'
          home "/home/#{service_user}"
          shell '/bin/bash'
          not_if { service_user == 'root' }
        end

        directory "/home/#{service_user}" do
          owner service_user
          group service_user
          mode '0750'
          recursive true
          action :create
          not_if { service_user == 'root' }
        end

        group service_group do
          members service_user
          append true
          not_if { service_group == 'root' }
        end

        directory log_dir do
          owner service_user
          group service_group
          mode '0755'
          recursive true
          action :create
        end

        date = Time.now.strftime('%d%b%Y-%H%M')
        main_pkg = package.split(',').first
        main_pkg = main_pkg.split('_').first
        logfile = "#{main_pkg}-install-#{date}.log"

        # packages_str = packages.join(' ') if packages
        repositories_str = repositories.join(', ') if repositories
        properties_str = properties.map { |k, v| "#{k}=#{v}" }.join(',') if properties
        preferences_str = preferences.map { |k, v| "#{k}=#{v}" }.join(',') if preferences

        options = "-installationDirectory '#{install_dir}' -accessRights '#{access_rights}' "\
        "-log #{log_dir}/#{logfile} -acceptLicense #{additional_options}"

        options << " -repositories '#{repositories_str}' " if repositories
        options << ' -connectPassportAdvantage' if passport_advantage
        options << " -masterPasswordFile #{master_pw_file} -secureStorageFile #{secure_storage_file}" if master_pw_file
        options << " -properties #{properties_str}" if properties
        options << " -preferences #{preferences_str}" if preferences

        imcl_wrapper(imcl_dir, "./imcl install '#{package}' -showProgress", options)
      end
    end

    # need to wrap helper methods in class_eval
    # so they are available in the action.
    action_class.class_eval do
      def imcl_wrapper(_imcl_directory, cmd, options)
        command = "#{cmd} #{options}"

        execute "imcl install #{package}" do
          cwd imcl_dir
          command command
          sensitive sensitive_exec
          action :run
        end
      end
    end
  end
end
