
include_recipe 'ibm-im-test::install_im'

ibm_response_file '/opt/IBM/response_files/my_was_response.xml' do
  cookbook 'ibm-im-test'
  template_source 'was_response.xml.erb'
end

ibm_package_response '/opt/IBM/response_files/my_was_response.xml' do
  imcl_dir '/opt/IBM/InstallationManager/eclipse/tools'
  action :install
end
