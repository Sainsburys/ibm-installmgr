require 'spec_helper'

describe 'ibm-im-test::install_was' do
  cached(:centos_67_install_was) do
    ChefSpec::ServerRunner.new(
      step_into: 'ibm_package',
      platform: 'centos',
      version: '6.7'
    ) do |node|
      # node.set['httpd']['version'] = '2.2'
    end.converge('ibm-im-test::install_was')
  end

  # test recipe compilation
  context 'when compiling the recipe' do
    it 'includes the installation manager recipe' do
      expect(centos_67_install_was).to include_recipe('ibm-im-test::install_im')
    end
  end

  context 'when stepping into ibm_package resource' do
    it 'creates ibm user' do
      expect(centos_67_install_was).to create_user('ibm').with(home: '/home/ibm')
    end

    it 'creates ibm home dir' do
      expect(centos_67_install_was).to create_directory('/home/ibm').with(
        user:   'ibm',
        group:  'ibm',
        mode:   '0750'
      )
    end

    it 'creates ibm group ' do
      expect(centos_67_install_was).to create_group('ibm')
    end

    it 'creates log directory /var/ibm/InstallationManager/logs' do
      expect(centos_67_install_was).to create_directory('/var/ibm/InstallationManager/logs').with(
        user:   'ibm',
        group:  'ibm',
        mode:   '0755'
      )
    end

    it 'executes imcl install' do
      expect(centos_67_install_was).to run_execute('imcl install command')
    end
  end
end
