# frozen_string_literal: true

require "English"
require "rspec/retry"
require "net/ssh"
require "pathname"
require "vagrant/serverspec"
require "vagrant/ssh/config"
require "ansibleinventory"
require "ansible/vault"
$LOAD_PATH.unshift(Pathname.new(File.dirname(__FILE__)).parent / "ruby" / "lib")

ENV["LANG"] = "C"

ENV["ANSIBLE_ENVIRONMENT"] = "virtualbox" unless ENV["ANSIBLE_ENVIRONMENT"]

# XXX OpenBSD needs TERM when installing packages
ENV["TERM"] = "xterm"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "default"
  config.verbose_retry = true
  config.display_try_failure_messages = true
end

# Returns ANSIBLE_ENVIRONMENT
#
# @return [String] ANSIBLE_ENVIRONMENT if defined in ENV. defaults to "staging"
def test_environment
  ENV.key?("ANSIBLE_ENVIRONMENT") ? ENV["ANSIBLE_ENVIRONMENT"] : "virtualbox"
end

# Returns inventory object
#
# @return [AnsibleInventory]
def inventory
  AnsibleInventory.new(inventory_path)
end

# Returns path to inventory file
#
# @return [String]
def inventory_path
  Pathname.new(__FILE__)
          .parent
          .parent / "inventories" / test_environment
end

# Returns YAML content as hash
def credentials_yaml
  file = Pathname.new("playbooks") / "group_vars" / "#{test_environment}-credentials.yml"
  YAML.safe_load(Ansible::Vault.decrypt(file: file))
rescue RuntimeError
  YAML.load_file(file)
end
