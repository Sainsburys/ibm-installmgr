
Cookbook TESTING doc
====================

Testing Prerequisites
---------------------
This cookbook tries to emulate the testing standards in https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/TESTING.MD

Style Testing
-------------
Ruby style tests can be performed by Rubocop by issuing either
```
bundle exec rubocop
```
or
```
rake style:ruby
```

Chef style/correctness tests can be performed with Foodcritic by issuing either
```
bundle exec foodcritic
```
or
```
rake style:chef
```

Spec Testing
-------------
```
rake unit
```

Integration Testing
-------------------
 At the moment you can run the kitchen suites with Vagrant, however you will need to have the WAS 8.5 installation kit available at /opt/ibm-media/WASND in the vagrant vm.
You can do this in your kitchen.local.yml with something like
```
---
suites:
  - name: was_install
    driver:
      synced_folders:
        - ["~/my-media-folder", "/opt/ibm-media"]
    run_list:
    - recipe[ibm-im-test::install_was]
  - name: was_install_response
    driver:
      synced_folders:
        - ["~/my-media-folder", "/opt/ibm-media"]
    run_list:
    - recipe[ibm-im-test::install_was_response]
```

 We are currently working on smoothing out this process.

 There is currently no ChefSpec tests due to the dependency on installation media for IBM packages.

```
bundle exec kitchen test
```
or
```
rake integration:vagrant
```
