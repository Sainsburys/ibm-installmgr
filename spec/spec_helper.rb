require 'chefspec'
require 'chefspec/berkshelf'

def stub_commands
  stub_command('which sudo').and_return('/usr/bin/sudo')
end

RSpec.configure do |config|
  config.platform = 'centos'
  config.version = '6.8'
  config.log_level = :error
  config.file_cache_path = '/tmp/cache'

  # Prohibit using the should syntax
  config.expect_with :rspec do |spec|
    spec.syntax = :expect
  end
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
