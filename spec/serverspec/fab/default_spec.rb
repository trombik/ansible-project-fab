# frozen_string_literal: true

require_relative "../spec_helper"

default_config_dir = "/usr/local/etc"
default_user = "root"
default_group = "wheel"

workers = %w[
  app
  worker
]

services = %w[
  postgresql
  redis
  supervisord
]

ports = [
  80,   # haproxy
  443,  # haproxy TLS
  5000, # rails
  5432, # postgrsql
  6379, # redis
  8001  # nginx
]

cert_dir = "/usr/local/etc/ssl/haproxy"
cert_file = case test_environment
            when "virtualbox"
              "localhost.pem"
            else
              "fab.mkrsgh.org.pem"
            end
cert_file_full_path = "#{cert_dir}/#{cert_file}"

describe command "echo" do
  its(:exit_status) { should eq 0 }
end

describe command "haproxy -c -f /usr/local/etc/haproxy.cfg" do
  its(:exit_status) { should eq 0 }
  # raise error when configuration file has _possible_ errors, which are not
  # critical, but indicate possible errors
  #
  # XXX `haproxy -c` has inconsistency. when invoked from command line, the
  # output goes to stderr. but without terminal, it goes to stdout. test both
  # just in case.
  its(:stdout) do
    pending "logging from haproxy is not yet implemented"
    should_not match(/WARNING/)
  end
  its(:stderr) { should_not match(/WARNING/) }
end

describe command "supervisorctl status" do
  its(:exit_status) { should eq 0 }
  workers.each do |worker|
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/^#{worker}\s+RUNNING\s+/) }
  end
end

services.each do |s|
  describe service(s) do
    it { should be_enabled }
    it { should be_running }
  end
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe file cert_dir do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by "www" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 755 }
end

describe file "#{cert_dir}/#{cert_file}" do
  it { should exist }
  it { should be_file }
  it { should be_owned_by "www" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 460 }
end

# test HTTP redirect to HTTPS
describe command "curl --verbose --header 'Host: fab.mkrsgh.org' http://127.0.0.1" do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/#{Regexp.escape("HTTP/1.1 302")}/) }
  its(:stdout) { should match(/#{Regexp.escape("location: https://fab.mkrsgh.org/")}/) }
end

curl_test_option = case test_environment
                   when "virtualbox"
                     "--verbose --insecure --header 'Host: fab.mkrsgh.org' https://127.0.0.1"
                   else
                     "--verbose --cacert #{cert_file_full_path.shellescape} --header 'Host: fab.mkrsgh.org' --connect-to 127.0.0.1:443 https://fab.mkrsgh.org"
                   end
describe command "curl #{curl_test_option}" do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/#{Regexp.escape("HTTP/1.1 200 OK")}/) }
  its(:stdout) { should match(/#{Regexp.escape("<title>Fab-manager</title>")}/) }
  its(:stdout) { should match(/SSL certificate verify ok/) } if test_environment != "virtualbox"
  its(:stdout) { should_not match(/X-Backend: nginx-servers/i) }
  its(:stdout) { should match(/X-Backend: servers/i) }
end

# test acme backend
describe command "curl --verbose --header 'Host: fab.mkrsgh.org' http://127.0.0.1/.well-known/acme-challenge/" do
  its(:exit_status) { should eq 0 }
  # XXX test HTTP status 503 here because acme backend is only available when
  # acme client is running.
  its(:stdout) { should match(/#{Regexp.escape("HTTP/1.1 503")}/) }
end

describe command "curl --verbose --insecure --header 'Host: fab.mkrsgh.org' https://127.0.0.1/packs/manifest.json" do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/#{Regexp.escape("HTTP/1.1 200")}/) }
  its(:stdout) { should match(/X-Backend: servers/i) }
end

describe command "curl --verbose --insecure --header 'Host: fab.mkrsgh.org' https://127.0.0.1/packs/static/no-such-file" do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/#{Regexp.escape("HTTP/1.1 404")}/) }
  its(:stdout) { should match(/X-Backend: nginx-servers/i) }
  its(:stdout) { should match(/If you are the application owner check the logs for more information/) }
end

describe file "#{default_config_dir}/supervisor/supervisord.conf" do
  it { should exist }
  it { should be_file }
  it { should be_mode 600 }
  it { should be_grouped_into default_group }
  it { should be_owned_by default_user }
end
