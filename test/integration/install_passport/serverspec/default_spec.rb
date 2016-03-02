require 'spec_helper'

describe user('ibm') do
  it { should exist }
  it { belong_to_group 'ibm' }
end

describe group('ibm') do
  it { should exist }
end

describe file('/opt/IBM/InstallationManager/eclipse/tools/imcl') do
  it { should exist }
end

describe command('/opt/IBM/InstallationManager/eclipse/tools/imcl listInstalledPackages') do
  its(:stdout) { should match(/com.ibm.cic.packagingUtility.*/) }
end
