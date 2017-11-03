
#
# Cookbook Name:: ibm-installmgr
# Resource:: ibm_package
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
    require_relative 'helpers'
    include InstallMgrHelpers

    resource_name :ibm_package
    property :package, String, required: true # eg 'com.ibm.websphere.ND.v85_8.5.5000.20130514_1044'
    property :install_dir, String, required: true
    property :imcl_dir, String, default: '/opt/IBM/InstallationManager/eclipse/tools'
    property :repositories, [String, Array, nil], default: nil
    property :passport_advantage, [TrueClass, FalseClass], default: false
    property :service_user, String, default: 'ibm'
    property :service_group, String, default: 'ibm'
    property :properties, [Hash, nil], default: nil
    property :preferences, [Hash, nil], default: nil
    property :install_fixes, String, default: 'none', regex: /^(none|recommended|all)$/
    property :additional_options, String, default: ''
    property :access_rights, String, default: 'admin', regex: /^(nonAdmin|admin|group)$/
    property :log_dir, String, default: '/var/IBM/InstallationManager/logs'
    property :secure_storage_file, [String, nil], default: nil
    property :master_pw_file, [String, nil], default: nil
    property :sensitive_exec, [TrueClass, FalseClass], default: true # only turn this off in exceptional debugging circumstances.

    # TODO: Include the below properties at some stage
    # property :install_fixes, String, default: 'none', :regex => /^(none|recommended|all)$/
    # property :preferences, [Hash], default: nil
    # property :properties, [Hash], default: nil

    provides :ibm_package if defined?(provides)

    action :install do
      unless package_installed?(new_resource.package, new_resource.imcl_dir)

        directory new_resource.log_dir do
          owner new_resource.service_user
          group new_resource.service_group
          mode '0755'
          recursive true
          action :create
        end

        date = Time.now.strftime('%d%b%Y-%H%M')
        main_pkg = new_resource.package.split(',').first
        main_pkg = main_pkg.split('_').first
        logfile = "#{main_pkg}-install-#{date}.log"

        # packages_str = packages.join(' ') if packages
        repositories_str = new_resource.repositories.join(', ') if new_resource.repositories
        properties_str = properties.map { |k, v| "#{k}=#{v}" }.join(',') if new_resource.properties
        preferences_str = preferences.map { |k, v| "#{k}=#{v}" }.join(',') if new_resource.preferences

        options = "-installationDirectory '#{new_resource.install_dir}' "\
        "-accessRights '#{new_resource.access_rights}' -log #{new_resource.log_dir}/#{logfile} "\
        "-acceptLicense #{new_resource.additional_options}"

        options << " -repositories '#{repositories_str}' " if new_resource.repositories
        options << " -installFixes #{new_resource.install_fixes}"
        options << ' -connectPassportAdvantage' if new_resource.passport_advantage
        options << " -masterPasswordFile #{new_resource.master_pw_file} -secureStorageFile #{secure_storage_file}" if new_resource.master_pw_file
        options << " -properties #{properties_str}" if new_resource.properties
        options << " -preferences #{preferences_str}" if new_resource.preferences

        imcl_wrapper(new_resource.imcl_dir, "./imcl install '#{new_resource.package}' -showProgress", options)
      end
    end

    # need to wrap helper methods in class_eval
    # so they are available in the action.
    action_class.class_eval do
      def imcl_wrapper(_imcl_directory, cmd, options)
        command = "#{cmd} #{options}"

        execute "imcl install #{new_resource.package}" do
          cwd new_resource.imcl_dir
          command command
          sensitive new_resource.sensitive_exec
          user new_resource.service_user
          group new_resource.service_group
          action :run
        end
      end
    end
  end
end
