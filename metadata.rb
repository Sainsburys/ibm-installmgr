name 'ibm-installmgr'
maintainer 'Sainsburys Digital'
maintainer_email 'GOL.CloudEngineering@sainsburys.co.uk'
license 'Apache-2.0'
description 'Installs/Configures IBM Installation Manager'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.3.1'
supports 'redhat'
supports 'centos'

issues_url 'https://github.com/Sainsburys/ibm-installmgr/issues'
source_url 'https://github.com/Sainsburys/ibm-installmgr'
chef_version '>= 12.5' if respond_to?(:chef_version)
