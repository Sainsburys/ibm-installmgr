require 'spec_helper'

describe 'ibm-im-test::install_passport' do
  cached(:centos_67_install_passport) do
    ChefSpec::ServerRunner.new(
      step_into: %w(ibm_secure_storage_file ibm_package),
      platform: 'centos',
      version: '6.6'
    ) do |node|
      node.set['ibm-im-test']['passport_advantage']['user'] = 'dummyuser'
      node.set['ibm-im-test']['passport_advantage']['password'] = 'dummypw'
    end.converge('ibm-im-test::install_passport')
  end

  # test recipe compilation
  context 'when compiling the recipe' do
    it 'includes the install_im package' do
      expect(centos_67_install_passport).to include_recipe('ibm-im-test::install_im')
    end
  end

  context 'when stepping into ibm_secure_storage_file' do
    it 'creates a file with the default action' do
      expect(centos_67_install_passport).to create_file('/root/MyMasterPassFile').with(
        mode: '0600',
        content: 'mypassphrase',
        sensitive: true
      )
    end

    it 'executes imcl install' do
      expect(centos_67_install_passport).to run_execute('imutilsc command /root/MySecureStorageFile').with(sensitive: true)
    end
  end

  context 'when stepping into ibm_package' do
    it 'creates ibm user' do
      expect(centos_67_install_passport).to create_user('ibm').with(home: '/home/ibm')
    end

    it 'creates ibm home dir' do
      expect(centos_67_install_passport).to create_directory('/home/ibm').with(
        user:   'ibm',
        group:  'ibm',
        mode:   '0750'
      )
    end

    it 'creates ibm group ' do
      expect(centos_67_install_passport).to create_group('ibm')
    end

    it 'creates log directory /var/IBM/InstallationManager/logs' do
      expect(centos_67_install_passport).to create_directory('/var/IBM/InstallationManager/logs').with(
        user:   'ibm',
        group:  'ibm',
        mode:   '0755'
      )
    end

    it 'executes imcl install' do
      expect(centos_67_install_passport).to run_execute('imcl install com.ibm.cic.packagingUtility').with(sensitive: true)
    end
  end
end
