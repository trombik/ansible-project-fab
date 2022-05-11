# frozen_string_literal: true

require_relative "../spec_helper"

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
  80,
  5000,
  5432,
  6379,
]

describe command "echo" do
  its(:exit_status) { should eq 0 }
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
