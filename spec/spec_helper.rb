require 'chefspec'
require 'chefspec/berkshelf'

def stub_commands
  stub_command('which sudo').and_return('/usr/bin/sudo')
end

at_exit { ChefSpec::Coverage.report! }
