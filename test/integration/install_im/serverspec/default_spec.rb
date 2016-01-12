require 'spec_helper'

describe user('ibm-im') do
  it { should exist }
  it { belong_to_group 'ibm-im' }
end

describe group('ibm-im') do
  it { should exist }
end

describe file('/opt/ibm/InstallationManager/eclipse/tools/imcl') do
  it { should exist }
end

describe command('/opt/ibm/InstallationManager/eclipse/tools/imcl listInstalledPackages') do
  its(:stdout) { should match(/com.ibm.cic.agent.*/) }
end
