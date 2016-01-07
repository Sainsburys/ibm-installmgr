
include_recipe 'ibm-im-test::install_im'

ibm_secure_storage_file '/root/MySecureStorageFile' do
  master_pw_file '/root/MyMasterPassFile'
  master_pw 'mypassphrase'
  passport_advantage true
  username node['ibm-im-test']['passport_advantage']['user']
  password node['ibm-im-test']['passport_advantage']['password']
end

ibm_package 'IHS install' do
  packages ['com.ibm.cic.packagingUtility']
  install_dir '/opt/IBM/PackagingUtility'
  passport_advantage true
  imcl_dir '/opt/IBM/InstallationManager/eclipse/tools'
  master_pw_file '/root/MyMasterPassFile'
  secure_storage_file '/root/MySecureStorageFile'
  action :install
end
