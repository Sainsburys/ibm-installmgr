
#
# Cookbook Name:: ibm-installmgr
# Resource:: ibm_secure_storage_file
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
  class IbmSecureStorageFile < Chef::Resource
    resource_name :ibm_secure_storage_file
    property :secure_file, String, name_property: true
    property :master_pw_file, [String, nil], default: nil
    property :master_pw, [String, nil], default: nil
    property :url, String, default: 'http://www.ibm.com/software/repositorymanager/entitled/repository.xml'
    property :imutilsc_dir, String, default: '/opt/IBM/InstallationManager/eclipse/tools'
    property :passport_advantage, [TrueClass, FalseClass], default: false
    property :username, [String, nil], default: nil
    property :password, [String, nil], default: nil
    property :sensitive_exec, [TrueClass, FalseClass], default: true

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
