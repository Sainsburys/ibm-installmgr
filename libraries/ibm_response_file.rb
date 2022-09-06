#
# Cookbook:: ibm-installmgr
# Resource:: ibm_response_file
# Copyright:: 2015-2022 J Sainsburys
# License:: Apache License, Version 2.0
#

module InstallMgrCookbook
  class IbmResponseFile < Chef::Resource
    resource_name :ibm_response_file
    provides :ibm_response_file

    property :response_file, String, name_property: true
    property :group, String, default: 'ibm-im'
    property :owner, String, default: 'ibm-im'
    property :template_source, [String, nil]
    property :cookbook, [String, nil]
    property :variables, [Hash, nil]

    action :create do
      config_dir = ::File.dirname(new_resource.response_file)

      directory config_dir do
        owner new_resource.owner
        group new_resource.group
        mode '0750'
        recursive true
        action :create
      end

      template "response_file :create #{new_resource.response_file}" do
        path new_resource.response_file
        owner new_resource.owner
        group new_resource.group
        mode '0750'
        source new_resource.template_source
        cookbook new_resource.cookbook
        variables new_resource.variables
        action :create
      end
    end
  end
end
