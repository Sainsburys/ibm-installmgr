#
# Cookbook:: ibm-installmgr
# Copyright:: 2015-2022 J Sainsburys
# License:: Apache License, Version 2.0
#

module InstallMgrCookbook
  module InstallMgrHelpers
    def package_installed?(package, imcl_dir, fixpack = false)
      main_pkg = package.split(',').first
      main_pkg = main_pkg.split('_').first unless fixpack
      mycmd = Mixlib::ShellOut.new('./imcl listInstalledPackages', cwd: imcl_dir)
      mycmd.run_command
      mycmd.stdout.split(/\n/).map do |pkg|
        return true if pkg.include? main_pkg
      end
      false
    end
  end
end
