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
