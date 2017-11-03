#
# Cookbook Name:: ibm-installmgr
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
  module InstallMgrHelpers
    def package_installed?(package, imcl_dir, fixpack = false)
      main_pkg = package.split(',').first
      main_pkg = main_pkg.split('_').first unless fixpack
      mycmd = Mixlib::ShellOut.new(
        './imcl listInstalledPackages',
        :user => node['was']['service_user'],
        :group => node['was']['service_group'],
        cwd: imcl_dir
      )
      mycmd.run_command
      mycmd.stdout.include? main_pkg
    end
  end
end
