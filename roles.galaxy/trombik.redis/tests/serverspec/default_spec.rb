require "spec_helper"
require "serverspec"

redis_package_name = case os[:family]
                     when "ubuntu", "devuan"
                       "redis-server"
                     when "freebsd", "openbsd", "redhat", "fedora"
                       "redis"
                     else
                       raise format("unknown os[:family]: `%s`", os[:family])
                     end
redis_service_name = case os[:family]
                     when "ubuntu", "devuan"
                       "redis-server"
                     else
                       "redis"
                     end
redis_conf_dir     = case os[:family]
                     when "freebsd"
                       "/usr/local/etc/redis"
                     else
                       "/etc/redis"
                     end
redis_config       = "#{redis_conf_dir}/redis.conf"
redis_user         = case os[:family]
                     when "openbsd"
                       "_redis"
                     else
                       "redis"
                     end
redis_group        = case os[:family]
                     when "openbsd"
                       "_redis"
                     else
                       "redis"
                     end
redis_dir          = case os[:family]
                     when "ubuntu", "redhat", "fedora", "devuan"
                       "/var/lib/redis"
                     when "freebsd"
                       "/var/db/redis"
                     when "openbsd"
                       "/var/redis"
                     end
redis_log_dir      = "/var/log/redis"
redis_logfile      = case os[:family]
                     when "freebsd", "redhat", "fedora", "openbsd"
                       "#{redis_log_dir}/redis.log"
                     when "ubuntu", "devuan"
                       "#{redis_log_dir}/redis-server.log"
                     end
redis_pid_dir      = "/var/run/redis"
redis_pidfile      = "#{redis_pid_dir}/#{redis_service_name}.pid"
redis_password = "password"
redis_port = 6379
redis_config_ansible = "#{redis_config}.ansible"

describe package(redis_package_name) do
  it { should be_installed }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/redis") do
    it { should be_file }
    its(:content) { should match Regexp.escape('redis_config="/usr/local/etc/redis/redis.conf"') }
  end
end

describe file(redis_log_dir) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by redis_user }
  it { should be_grouped_into redis_group }
end

describe file(redis_dir) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by redis_user }
  it { should be_grouped_into redis_group }
end

describe file redis_pid_dir do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by redis_user }
  it { should be_grouped_into redis_group }
  case os[:family]
  when "openbsd"
    it { should be_mode 750 }
  when "ubuntu"
    it { should be_mode 2755 }
  else
    it { should be_mode 755 }
  end
end

describe file(redis_config) do
  it { should be_file }
  it { should be_owned_by redis_user }
  it { should be_grouped_into redis_group }
  its(:content) { should match(/^include #{Regexp.escape(redis_config_ansible)}/) }
  its(:content) { should_not match(/^slaveof /) }
end

describe file(redis_config_ansible) do
  it { should be_file }
  its(:content) { should match(/Managed by ansible/) }
  its(:content) { should match Regexp.escape("pidfile #{redis_pidfile}") }
  if redis_logfile
    its(:content) { should match Regexp.escape("logfile #{redis_logfile}") }
  end
  its(:content) { should match Regexp.escape("dir #{redis_dir}") }
  its(:content) { should match(/^port 6379/) } # default
  its(:content) { should match(/^databases 17$/) } # non-default
end

if redis_logfile
  describe file(redis_logfile) do
    it { should be_file }
    it { should be_owned_by redis_user }
    it { should be_grouped_into redis_group }
  end
end

describe service(redis_service_name) do
  it { should be_running }
  it { should be_enabled }
end

describe port(redis_port) do
  it { should be_listening }
end

describe command "redis-cli -a #{redis_password} ping" do
  its(:stdout) { should match(/PONG/) }
  if os[:family] != "redhat"
    its(:stderr) { should eq "Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.\n" }
  else
    its(:stderr) { should eq "" }
  end
  its(:exit_status) { should eq 0 }
end

describe command "redis-cli ping" do
  its(:stdout) { should match(/NOAUTH Authentication required/) }
  its(:stderr) { should eq "" }
  its(:exit_status) { should eq 0 }
end
