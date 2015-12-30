
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
  class IbmSecureStorageFile < Chef::Resource
    resource_name :ibm_secure_storage_file
    property :secure_file, String, name_property: true
    property :master_pw_file, String, default: nil
    property :url, String, default: 'http://www.ibm.com/software/repositorymanager/entitled/repository.xml'
    property :passportAdvantage, [TrueClass, FalseClass], default: false
    property :username, String, default: nil
    property :password, String, default: nil

    action :create do
      # if passportAdvantage ignore url.
      config_dir = ::File.dirname(secure_file)

      directory config_dir do
        mode '0640'
        recursive true
        action :create
      end

      if passportAdvantage
        command = "./imutilsc saveCredential  -passportAdvantage -userName \"#{username}\" -userPassword "\
        "\"#{password}\" -secureStorageFile \"#{secure_file}\" -masterPasswordFile \"#{master_pw_file}\""
      else
        command = "./imutilsc saveCredential  -url \"#{url}\" -userName \"#{username}\" -userPassword "\
        "\"#{password}\" -secureStorageFile \"#{secure_file}\" -masterPasswordFile \"#{master_pw_file}\""
      end

      execute "imcl command #{cmd} #{options}" do
        cwd imcl_dir
        command command
        action :run
      end
    end
  end
end
