# frozen_string_literal: true

require_relative "../spec_helper"

cert_dir = "/usr/local/etc/ssl/haproxy"

describe file cert_dir do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by "www" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 755 }
end

describe file "#{cert_dir}/fab.mkrsgh.org.pem" do
  it { should exist }
  it { should be_file }
  it { should be_owned_by "www" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 460 }
end

describe command "curl --verbose --cacert /usr/local/etc/ssl/cert.pem --header 'Host: fab.mkrsgh.org' --connect-to 127.0.0.1:443 https://fab.mkrsgh.org" do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/SSL certificate verify ok/) }
  its(:stdout) { should match(/#{Regexp.escape("HTTP/1.1 200 OK")}/) }
  its(:stdout) { should match(/#{Regexp.escape("<title>Fab-manager</title>")}/) }
end
