require "spec_helper"
require "serverspec"

package = case os[:family]
          when "freebsd"
            "sysutils/py-supervisor"
          when "openbsd", "ubuntu", "fedora", "devuan"
            "supervisor"
          else
            raise "unknown os[:family]: `#{os[:family]}`"
          end
service = case os[:family]
          when "freebsd", "openbsd", "fedora"
            "supervisord"
          when "ubuntu", "devuan"
            "supervisor"
          end
config_dir = case os[:family]
             when "freebsd"
               "/usr/local/etc/supervisor"
             when "fedora"
               "/etc"
             else
               "/etc/supervisor"
             end
conf_d_dir = case os[:family]
             when "fedora"
               "#{config_dir}/supervisord.d"
             else
               "#{config_dir}/conf.d"
             end
config  = "#{config_dir}/supervisord.conf"
user    = "root"
group   = case os[:family]
          when "freebsd", "openbsd"
            "wheel"
          else
            "root"
          end
ports   = []
log_dir = "/var/log/supervisor"
log_file = "/var/log/supervisor/supervisord.log"
unix_socket_dir = case os[:family]
                  when "freebsd", "openbsd"
                    "/var/run/supervisor"
                  when "ubuntu", "devuan"
                    "/var/run"
                  when "fedora"
                    "/run/supervisor"
                  end
unix_socket_file = "#{unix_socket_dir}/supervisor.sock"
pid_dir = case os[:family]
          when "freebsd", "openbsd"
            "/var/run/supervisor"
          when "fedora"
            "/run"
          when "ubuntu", "devuan"
            "/var/run"
          end

describe package(package) do
  it { should be_installed }
end

describe file config_dir do
  it { should exist }
  it { should be_directory }
  if config_dir != "/etc"
    it { should be_owned_by user }
    it { should be_grouped_into group }
    it { should be_mode 755 }
  end
end

describe file conf_d_dir do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 755 }
end

describe file conf_d_dir do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 755 }
end

describe file pid_dir do
  it { should exist }
  it { should be_directory }
  if pid_dir != "/var/run" && pid_dir != "/run"
    it { should be_owned_by user }
    it { should be_grouped_into group }
    it { should be_mode 755 }
  end
end

describe file unix_socket_dir do
  it { should exist }
  it { should be_directory }
  if unix_socket_dir != "/var/run" && unix_socket_dir != "/run"
    it { should be_owned_by user }
    it { should be_grouped_into group }
    it { should be_mode 755 }
  end
end

describe file unix_socket_file do
  it { should exist }
  it { should be_socket }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 700 }
end

describe file config do
  it { should exist }
  it { should be_file }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 600 }
  its(:content) { should match Regexp.escape("Managed by ansible") }
end

case os[:family]
when "freebsd"
  describe file "/etc/rc.conf.d/#{service}" do
    it { should exist }
    it { should be_file }
    it { should be_owned_by user }
    it { should be_grouped_into group }
    it { should be_mode 644 }
    its(:content) { should match Regexp.escape("Managed by ansible") }
  end
when "openbsd"
  describe file "/etc/rc.conf.local" do
    it { should exist }
    it { should be_file }
    its(:content) { should match(/supervisord_flags=-c #{config}/) }
  end
end

describe file log_dir do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file log_file do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe command "supervisorctl -c #{config} pid" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/\d+/) }
end
