
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
    property :master_pw, String, default: nil
    property :url, String, default: 'http://www.ibm.com/software/repositorymanager/entitled/repository.xml'
    property :imutilsc_dir, String, default: '/opt/IBM/InstallationManager/eclipse/tools'
    property :passport_advantage, [TrueClass, FalseClass], default: false
    property :username, String, default: nil
    property :password, String, default: nil

    action :create do
      # create required dirs
      # %w(secure_file master_pw_file).each do |f|
      #   dir = ::File.dirname(f)
      #
      #   directory dir do
      #     mode '0600'
      #     recursive true
      #     action :create
      #     not_if { dir == '/root' || dir == '/home' }
      #   end
      # end

      file master_pw_file do
        content master_pw
        mode '0600'
        sensitive true
      end

      # if passportAdvantage ignore url.
      if passport_advantage
        cmd = "./imutilsc saveCredential  -passportAdvantage -userName \"#{username}\" -userPassword "\
        "\"#{password}\" -secureStorageFile \"#{secure_file}\" -masterPasswordFile \"#{master_pw_file}\""
      else
        cmd = "./imutilsc saveCredential  -url \"#{url}\" -userName \"#{username}\" -userPassword "\
        "\"#{password}\" -secureStorageFile \"#{secure_file}\" -masterPasswordFile \"#{master_pw_file}\""
      end

      execute 'imutilsc command' do
        cwd imutilsc_dir
        command cmd
        sensitive true
        action :run
      end
    end
  end
end
