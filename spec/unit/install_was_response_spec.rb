require 'spec_helper'

describe 'ibm-im-test::install_was_response' do
  cached(:centos_67_install_was) do
    ChefSpec::ServerRunner.new(
      step_into: 'ibm_package_response',
      platform: 'centos',
      version: '6.7'
    ) do |node|
    end.converge('ibm-im-test::install_was_response')
  end

  # test recipe compilation
  context 'when compiling the recipe' do
    it 'includes the installation manager recipe' do
      expect(centos_67_install_was).to include_recipe('ibm-im-test::install_im')
    end
  end

  context 'when stepping into ibm_package_response resource' do
    it 'creates log directory /var/ibm/InstallationManager/logs' do
      expect(centos_67_install_was).to create_directory('/var/ibm/InstallationManager/logs').with(
        user:   'ibm',
        group:  'ibm',
        mode:   '0755'
      )
    end

    it 'executes imcl install' do
      expect(centos_67_install_was).to run_execute('imcl input command')
    end
  end
end
