
include_recipe 'ibm-im-test::install_im'

ibm_response_file '/opt/ibm/response_files/my_was_response.xml' do
  cookbook 'ibm-im-test'
  template_source 'was_response.xml.erb'
end

ibm_package_response '/opt/ibm/response_files/my_was_response.xml' do
  imcl_dir '/opt/ibm/InstallationManager/eclipse/tools'
  action :install
end
