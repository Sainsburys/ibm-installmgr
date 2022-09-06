#
# Cookbook:: ibm-installmgr
# Resource:: ibm_package
#
# Copyright:: 2015-2022 J Sainsburys
# License:: Apache License, Version 2.0
#
require_relative 'ibm_package'

module InstallMgrCookbook
  class IbmFixPack < IbmPackage
    require_relative 'helpers'
    include InstallMgrHelpers

    resource_name :ibm_fixpack
    provides :ibm_fixpack

    action :install do
      unless package_installed?(new_resource.package, new_resource.imcl_dir, true)

        user new_resource.service_user do
          comment 'ibm installation mgr service account'
          home "/home/#{new_resource.service_user}"
          shell '/bin/bash'
          not_if { new_resource.service_user == 'root' }
        end

        directory "/home/#{new_resource.service_user}" do
          owner new_resource.service_user
          group new_resource.service_group
          mode '0750'
          recursive true
          action :create
          not_if { new_resource.service_user == 'root' }
        end

        group new_resource.service_group do
          members new_resource.service_user
          append true
          not_if { new_resource.service_group == 'root' }
        end

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
        properties_str = new_resource.properties.map { |k, v| "#{k}=#{v}" }.join(',') if new_resource.properties
        preferences_str = new_resource.preferences.map { |k, v| "#{k}=#{v}" }.join(',') if new_resource.preferences

        options = "-installationDirectory '#{new_resource.install_dir}' -accessRights '#{new_resource.access_rights}' "\
        "-log #{new_resource.log_dir}/#{logfile} -acceptLicense #{new_resource.additional_options}"

        options << " -repositories '#{repositories_str}' " if new_resource.repositories
        options << ' -connectPassportAdvantage' if new_resource.passport_advantage
        options << " -masterPasswordFile #{master_pw_file} -secureStorageFile #{new_resource.secure_storage_file}" if new_resource.master_pw_file
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
          action :run
        end
      end
    end
  end
end
