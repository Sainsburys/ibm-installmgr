
#
# Cookbook:: ibm-installmgr
# Resource:: ibm_secure_storage_file
# Copyright:: 2015-2022 J Sainsburys
# License:: Apache License, Version 2.0
#

module InstallMgrCookbook
  class IbmSecureStorageFile < Chef::Resource
    resource_name :ibm_secure_storage_file
    provides :ibm_secure_storage_file

    property :secure_file, String, name_property: true
    property :master_pw_file, [String, nil]
    property :master_pw, [String, nil]
    property :url, String, default: 'http://www.ibm.com/software/repositorymanager/entitled/repository.xml'
    property :imutilsc_dir, String, default: '/opt/IBM/InstallationManager/eclipse/tools'
    property :passport_advantage, [true, false], default: false
    property :username, [String, nil]
    property :password, [String, nil]
    property :sensitive_exec, [true, false], default: true

    action :create do
      file new_resource.master_pw_file do
        content new_resource.master_pw
        mode '0600'
        sensitive true
      end

      # if passportAdvantage ignore url.
      cmd = if new_resource.passport_advantage
              "./imutilsc saveCredential  -passportAdvantage -userName \"#{new_resource.username}\" -userPassword "\
              "\"#{new_resource.password}\" -secureStorageFile \"#{new_resource.secure_file}\" -masterPasswordFile \"#{new_resource.master_pw_file}\""
            else
              "./imutilsc saveCredential  -url \"#{new_resource.url}\" -userName \"#{new_resource.username}\" -userPassword "\
              "\"#{new_resource.password}\" -secureStorageFile \"#{new_resource.secure_file}\" -masterPasswordFile \"#{new_resource.master_pw_file}\""
            end

      execute "imutilsc command #{new_resource.secure_file}" do
        cwd new_resource.imutilsc_dir
        command cmd
        sensitive new_resource.sensitive_exec
        action :run
        not_if { ::File.exist?(new_resource.secure_file) }
      end
    end
  end
end
