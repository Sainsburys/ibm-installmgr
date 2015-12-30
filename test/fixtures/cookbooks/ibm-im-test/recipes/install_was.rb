
include_recipe 'ibm-im-test::install_im'

ibm_package 'WAS ND install' do
  # packages ['com.ibm.websphere.ND.v85_8.5.5000.20130514_1044']
  packages ['com.ibm.websphere.ND.v85']
  install_dir '/opt/IBM/WAS'
  repositories ['/opt/ibm-media/WASND']
  imcl_dir '/opt/IBM/InstallationManager/eclipse/tools'
  action :install
end
