if defined?(ChefSpec)

  def install_install_mgr(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:install_mgr, :install, resource_name)
  end

  def install_ibm_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ibm_package, :install, resource_name)
  end

  def install_ibm_fixpack(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ibm_fixpack, :install, resource_name)
  end

  def install_ibm_package_response(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ibm_package_response, :install, resource_name)
  end

  def creates_ibm_response_file(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ibm_response_file, :create, resource_name)
  end

  def creates_secure_storage_file(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ibm_secure_storage_file, :creates, resource_name)
  end

end
