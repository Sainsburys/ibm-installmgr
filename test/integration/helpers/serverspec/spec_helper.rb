require 'serverspec'

set :backend, :exec

set :path, '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:$PATH'
