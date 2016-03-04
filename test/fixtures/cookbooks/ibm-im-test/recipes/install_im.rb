
# install java
node.default['java']['jdk_version'] = '7'
node.default['java']['install_flavor'] = 'openjdk'

include_recipe 'java'

install_mgr 'ibm-im install' do
  install_package 'https://s3-eu-west-1.amazonaws.com/jsidentity/media/agent.installer.linux.gtk.x86_64_1.8.4000.20151125_0201.zip'
  install_package_sha256 '28f5279abc28695c0b99ae0c3fdee26bfec131186f2ca7e41d1317e303adb12e'
  package_name 'com.ibm.cic.agent'
  ibm_root_dir '/opt/IBM'
  service_user 'ibm-im'
  service_group 'ibm-im'
end
