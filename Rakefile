# frozen_string_literal: true

require "rake"
require "pathname"
require "shellwords"
require "json"
require "ansibleinventory"
require "vagrant/serverspec"
require "vagrant/ssh/config"
require "retries"

ENV["PROJECT_ENVIRONMENT"] = ENV.fetch("PROJECT_ENVIRONMENT", "virtualbox")

def ansible_environment
  ENV.fetch("PROJECT_ENVIRONMENT", nil)
end

def inventory_path
  "inventories/#{ansible_environment}"
end

def configure_sudo_password_for(user)
  ENV["SUDO_PASSWORD"] = sudo_password if
    sudo_password_required?(user) &&
    !ENV.key?("SUDO_PASSWORD")
end

def run_as_user
  return ENV.fetch("ANSIBLE_USER", nil) if ENV["ANSIBLE_USER"]

  case ansible_environment
  when "virtualbox"
    "vagrant"
  when "staging"
    "ec2-user"
  end
end

def sudo_password_required?(user)
  user != "root" && user != "vagrant" && user != "ec2-user"
end

desc "up"
task "up" do
  case ansible_environment
  when "virtualbox"
    Bundler.with_original_env do
      sh "vagrant up --no-provision"
    end
  when "staging"
    Dir.chdir "terraform/plans/staging" do
      sh "terraform apply"
    end

    # make sure all hosts are ready for ansible play
    retry_opts = {
      max_tries: 10, base_sleep_seconds: 10, max_sleep_seconds: 30
    }
    with_retries(retry_opts) do |_attempt_number|
      sh "ansible -i #{inventory_path.shellescape} " \
         "--ssh-common-args='-o \"UserKnownHostsFile /dev/null\" -o \"StrictHostKeyChecking no\"' " \
         "-m ping all"
    end
  end
end

desc "provision"
task "provision" do
  case ansible_environment
  when "virtualbox"
    Bundler.with_original_env do
      sh "vagrant provision"
    end
  when "staging"
    sh "ansible-playbook -i #{inventory_path.shellescape} " \
       "--ssh-common-args='-o \"UserKnownHostsFile /dev/null\" -o \"StrictHostKeyChecking no\"' " \
       "playbooks/site.yml"
  end
end

desc "destroy"
task "destroy" do
  case ansible_environment
  when "virtualbox"
    Bundler.with_original_env do
      sh "vagrant destroy -f"
    end
  when "staging"
    Dir.chdir "terraform/plans/staging" do
      sh "terraform apply --destroy"
    end
  end
end

namespace "show" do
  desc "inventory"
  task "inventory" do
    sh "ansible-inventory -i inventories/#{ansible_environment.shellescape} --list"
  end
end

namespace "spec" do
  desc "run serverspec on all hosts"
  task "serverspec" do
    # XXX set ANSIBLE_VERBOSE_TO_STDERR becasue AnsibleInventory parses output
    # of `ansible-inventory`, and if verbose is greater than 1, the output is
    # not valid YAML.
    #
    # XXX fix this issue in AnsibleInventory
    verbose_to_stderr_enabled = ENV.key?("ANSIBLE_VERBOSE_TO_STDERR")
    ENV["ANSIBLE_VERBOSE_TO_STDERR"] = "true"
    inventory = AnsibleInventory.new(inventory_path)

    inventory.all_groups.each do |g|
      next unless Dir.exist?("spec/serverspec/#{g}")

      puts "group: #{g}"
      inventory.all_hosts_in(g).each do |h|
        puts "host: #{h}"

        # XXX pass SUDO_PASSWORD to serverspec if the user is required to
        # type password
        configure_sudo_password_for(run_as_user)
        puts "running serverspec for group `#{g}` on host `#{h}` as user `#{run_as_user}`"
        case ansible_environment
        when "virtualbox"
          Vagrant::Serverspec.new(inventory_path).run(group: g, hostname: h)
        when "staging"
          dir = Pathname.new("spec") / "serverspec" / g
          sh "env PROJECT_ENVIRONMENT=staging TARGET_HOST=#{h.shellescape} rspec #{dir.to_s.shellescape}"
        end
      end
    end
    ENV.delete("ANSIBLE_VERBOSE_TO_STDERR") unless verbose_to_stderr_enabled
  end
end
