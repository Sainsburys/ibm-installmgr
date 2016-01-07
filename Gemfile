source 'https://rubygems.org'

group :ci do
  gem 'git'
end

group :lint do
  gem 'foodcritic'
  gem 'rubocop'
end

group :test do
  gem 'berkshelf', '~> 4'
  gem 'chefspec', github: 'jkeiser/chefspec', branch: 'jk/chefspec-12.5'
  gem 'kitchen-inspec'
end

group :kitchen_common do
  gem 'test-kitchen'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'
end

group :development do
  gem 'growl'
  gem 'rb-fsevent'
  gem 'guard'
  gem 'guard-kitchen'
  gem 'guard-foodcritic'
  gem 'guard-rubocop'
  gem 'fauxhai'
  gem 'pry-nav'
end
