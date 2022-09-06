#
# Cookbook:: ibm-installmgr
# Resource:: install_mgr
# Copyright:: 2015-2022 J Sainsburys
# License:: Apache License, Version 2.0
#

module InstallMgrCookbook
  class InstallMgr < Chef::Resource
    require_relative 'helpers'
    include InstallMgrHelpers

    resource_name :install_mgr
    property :install_package, String, required: true # can be url or local path to a compressed file
    property :install_package_sha256, [String, nil]
    property :download_temp_dir, String, default: Chef::Config['file_cache_path']
    property :extract_dir, String, default: lazy { "#{download_temp_dir}/ibm-installmgr" }
    property :install_dir, String, default: lazy { "#{ibm_root_dir}/InstallationManager/eclipse" }
    property :package_name, String, default: 'com.ibm.cic.agent'
    property :repositories, [String, Array], default: lazy { [extract_dir] }
    property :ibm_root_dir, String, default: '/opt/IBM'
    property :data_location, String, default: '/var/IBM/InstallationManager'
    property :service_user, String, default: 'ibm-im'
    property :service_group, String, default: 'ibm-im'
    property :access_rights, String, default: 'admin', regex: /^(nonAdmin|admin|group)$/
    property :preferences, String, default: 'offering.service.repositories.areUsed=false'

    provides :install_mgr

    action :install do
      unless package_installed?(new_resource.package_name, "#{new_resource.install_dir}/tools")

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

        # create required dirs
        dirs = [new_resource.ibm_root_dir.to_s, new_resource.extract_dir.to_s,\
                new_resource.install_dir.to_s, new_resource.data_location.to_s]
        dirs.each do |dir|
          directory dir do
            owner new_resource.service_user
            group new_resource.service_group
            mode '0750'
            recursive true
            action :create
            not_if { ::Dir.exist?(dir) }
          end
        end

        if new_resource.install_package
          if url?(new_resource.install_package)
            local_file = local_installer_file

            remote_file local_file do
              source new_resource.install_package
              owner new_resource.service_user
              group new_resource.service_group
              mode '0750'
              checksum new_resource.install_package_sha256
              action :create
            end
          end

          local_file = local_installer_file
          ext = ::File.extname(local_file)

          case ext
          when '.gz'
            extract_tar(local_file, new_resource.extract_dir)
          when '.tar'
            extract_tar(local_file, new_resource.extract_dir)
          when '.zip'
            extract_zip(local_file, new_resource.extract_dir)
          else
            Chef::Log.error('Unable to extract ibm Installation Manager Install package. It must be either tar, tar.gz or zip')
          end

        end

        repositories_str = new_resource.repositories.join(', ') if new_resource.repositories

        cmd = "./imcl install \"#{new_resource.package_name}\" "\
        "-installationDirectory \"#{new_resource.install_dir}\" "\
        "-accessRights \"#{new_resource.access_rights}\" "\
        "-acceptLicense -dataLocation \"#{new_resource.data_location}\" "\
        " -preferences #{new_resource.preferences}"
        cmd << " -repositories '#{repositories_str}' " if new_resource.repositories

        execute "install im #{new_resource.package_name}" do
          cwd "#{new_resource.extract_dir}/tools"
          command cmd
          action :run
        end

      end
    end

    # unfortunately need to wrap helper methods in class_eval
    # so they are available in the action.
    action_class.class_eval do
      def url?(string)
        checks = %w[http https file]
        checks.any? { |str| string.include? str }
      end

      # helper function to return valid path to installer zip/tar
      def local_installer_file
        if url?(new_resource.install_package)
          filename = ::File.basename(new_resource.install_package)
          local_file = "#{new_resource.download_temp_dir}/#{filename}"
        else
          local_file = new_resource.install_package
        end
        local_file
      end

      def extract_tar(local_file, target_dir)
        cmd = if ::File.extname(local_file) == '.gz'
                "tar -zxf #{local_file} --strip-components=1 --no-same-owner -C #{target_dir}"
              else
                "tar -xf #{local_file} --strip-components=1 --no-same-owner -C #{target_dir}"
              end

        execute 'untar ibm-im installer package' do
          command cmd
          not_if { ::File.exist?("#{target_dir}/tools") }
        end
      end

      def extract_zip(local_file, target_dir)
        package 'unzip'

        execute 'unzip ibm-im installer package' do
          command "unzip -o #{local_file} -d #{target_dir}"
          not_if { ::File.exist?("#{target_dir}/tools") }
        end
      end
    end
  end
end
