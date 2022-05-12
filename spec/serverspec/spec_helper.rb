# frozen_string_literal: true

require "serverspec"
require "net/ssh/proxy/command"
require_relative "../spec_helper"
$LOAD_PATH.unshift(
  "#{Pathname.new(File.dirname(__FILE__)).parent.parent}rubylib"
)

Dir["#{File.dirname(__FILE__)}/types/*.rb"].sort.each { |f| require f }
Dir["#{File.dirname(__FILE__)}/shared_examples/*.rb"].sort.each { |f| require f }

host = ENV.fetch("TARGET_HOST", nil)

proxy = nil
default_options = {}
options = {}

case test_environment
when "virtualbox"
  ssh_options = Vagrant::SSH::Config.for(host)
  proxy = if ssh_options.key?("ProxyCommand".downcase)
            Net::SSH::Proxy::Command.new(ssh_options["ProxyCommand".downcase])
          else
            false
          end

  options = {
    host_name: ssh_options["HostName".downcase],
    port: ssh_options["Port".downcase],
    user: ssh_options["User".downcase],
    keys: ssh_options["IdentityFile".downcase],
    keys_only: ssh_options["IdentitiesOnly".downcase],
    verify_host_key: ssh_options["StrictHostKeyChecking".downcase]
  }
when "staging", "prod"
  # proxy = Net::SSH::Proxy::Command.new(
  #   'ssh jumpguy@jump.server.enterprise.com nc %h %p'
  # )
  default_options = Net::SSH::Config.translate(
    Net::SSH::Config.load("#{Dir.home}/.ssh/config", inventory.host(host)["ansible_host"])
  )
  options = {
    host_name: inventory.host(host)["ansible_host"],
    keys_only: true,
    verify_host_key: test_environment == "prod" ? :always : :never
  }
end
options[:proxy] = proxy if proxy

set :backend, :ssh
set :sudo_password, ENV.fetch("SUDO_PASSWORD", nil)

set :host, host
set :ssh_options, default_options.merge(options)
set :request_pty, true
set :env, LANG: "C", LC_MESSAGES: "C"
