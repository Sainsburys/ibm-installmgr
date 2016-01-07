
#
# Cookbook Name:: websphere
# Resource:: websphere-server
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

module InstallMgrCookbook
  class IbmPackage < Chef::Resource
    resource_name :ibm_package
    property :packages, [String, Array], required: true, default: nil # eg 'com.ibm.websphere.ND.v85_8.5.5000.20130514_1044'
    property :install_dir, String, required: true, default: nil
    property :imcl_dir, String, default: '/opt/IBM/InstallationManager/eclipse/tools'
    property :repositories, [String, Array], default: nil
    property :passport_advantage, [TrueClass, FalseClass], default: false
    property :service_user, String, default: 'ibm'
    property :service_group, String, default: 'ibm'
    property :additional_options, String, default: ''
    property :access_rights, String, default: 'nonAdmin', regex: /^(nonAdmin|admin|group)$/
    property :log_dir, String, default: '/var/ibm/InstallationManager/logs'
    property :secure_storage_file, String, default: nil
    property :master_pw_file, String, default: nil

    # TODO: Include the below properties at some stage
    # property :install_fixes, String, default: 'none', :regex => /^(none|recommended|all)$/
    # property :preferences, [Hash], default: nil
    # property :properties, [Hash], default: nil

    provides :ibm_package if defined?(provides)

    action :install do
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
      logfile = "#{packages[0]}-install-#{date}.log"

      packages_str = packages.join(' ') if packages
      repositories_str = repositories.join(', ') if repositories

      options = "-installationDirectory '#{install_dir}' -accessRights '#{access_rights}' "\
      "-log #{log_dir}/#{logfile} -acceptLicense #{additional_options}"

      options << " -repositories '#{repositories_str}' " if repositories
      options << ' -connectPassportAdvantage' if passport_advantage
      options << " -masterPasswordFile #{master_pw_file} -secureStorageFile #{secure_storage_file}" if master_pw_file

      imcl_wrapper(imcl_dir, "./imcl install '#{packages_str}' -showProgress", options)
    end

    # need to wrap helper methods in class_eval
    # so they are available in the action.
    action_class.class_eval do
      def imcl_wrapper(_imcl_directory, cmd, options)
        command = "#{cmd} #{options}"

        execute 'imcl install command' do
          cwd imcl_dir
          command command
          action :run
        end
      end
    end
  end
end
