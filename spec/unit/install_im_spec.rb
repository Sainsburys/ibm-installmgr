require 'spec_helper'

describe 'ibm-im-test::install_im' do
  cached(:centos_67_install_im) do
    ChefSpec::ServerRunner.new(
      step_into: 'install_mgr',
      platform: 'centos',
      version: '6.6'
    ) do
    end.converge('ibm-im-test::install_im')
  end

  # test recipe compilation
  context 'when compiling the recipe' do
    it 'installs install_mgr[ibm-im install]' do
      expect(centos_67_install_im).to install_install_mgr('ibm-im install')
    end
  end

  context 'when stepping into install_mgr' do
    it 'creates ibm-im user' do
      expect(centos_67_install_im).to create_user('ibm-im').with(home: '/home/ibm-im')
    end

    it 'creates home dir' do
      expect(centos_67_install_im).to create_directory('/home/ibm-im').with(
        user:   'ibm-im',
        group:  'ibm-im',
        mode:   '0750'
      )
    end

    it 'creates ibm-im group ' do
      expect(centos_67_install_im).to create_group('ibm-im')
    end

    dirs = %w[ibm_root_dir extract_dir install_dir data_location]
    it 'creates these directories' do
      dirs.each do |dir|
        expect(centos_67_install_im).to create_directory(dir).with(
          user:   'ibm-im',
          group:  'ibm-im',
          mode:   '0750'
        )
      end
    end

    # it 'installs unzip package' do
    #   expect(centos_67_install_im).to install_yum_package('unzip')
    # end

    it 'executes unzip command' do
      expect(centos_67_install_im).to run_execute('unzip ibm-im installer package')
    end

    it 'executes imcl install' do
      expect(centos_67_install_im).to run_execute('install im com.ibm.cic.agent')
    end
  end
end
