require_relative '../../../kitchen/data/spec_helper'

describe user('ibm-im') do
  it { should exist }
  it { belong_to_group 'ibm-im' }
end

describe group('ibm-im') do
  it { should exist }
end
