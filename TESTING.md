
# Cookbook TESTING doc

## Testing Prerequisites

This cookbook tries to emulate the testing standards in https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/TESTING.MD

## Style Testing

Ruby style tests can be performed by Rubocop by issuing either

```shell
bundle exec rubocop
```

or

```shell
rake style:ruby
```

Chef style/correctness tests can be performed with Foodcritic by issuing either

```shell
bundle exec foodcritic
```

or

```shell
rake style:chef
```

## Spec Testing

```shell
rake unit
```

## Integration Testing

You can run the `install_im` suite without any media, as it's available in S3.

In order to run `install_passport` you need to set a Passport Advantage login in environment variables:

```shell
export PASSPORTADV_USER=myuser@myemail.com
export PASSPORTADV_PW=mypassword
```

Unfortunately a lot of the packages in the Passport Advantage repo are incomplete, so in order to run the kitchen suites with Vagrant you will need to have the WAS 8.5 installation kit available at /opt/ibm-media/WASND in the vagrant vm.
You can do this in your `.kitchen.local.yml` with something like

```yaml
---
suites:
  - name: install_im
    run_list:
    - recipe[ibm-im-test::install_im]
  - name: install_passport
    run_list:
    - recipe[ibm-im-test::install_passport]
  - name: install_was
    driver:
      synced_folders:
        - ["~/sainsburys/identity/media", "/opt/ibm-media"]
    run_list:
    - recipe[ibm-im-test::install_was]
  - name: install_was_response
    driver:
      synced_folders:
        - ["~/sainsburys/identity/media", "/opt/ibm-media"]
    run_list:
    - recipe[ibm-im-test::install_was_response]
```

 We are currently working on smoothing out this process.

```shell
bundle exec kitchen test
```

or

```shell
rake integration:vagrant
```
