require "spec_helper"
require "serverspec"

sysctl_bin = "/sbin/sysctl"
sysctl_conf = "/etc/sysctl.conf"
sysctl = {}

case os[:family]
when "freebsd", "openbsd"
  sysctl = {
    "net.inet.ip.forwarding" => "1",
    "kern.maxfiles" => "20000"
  }
when "redhat"
  sysctl_conf = "/etc/sysctl.d/99-sysctl.conf"
  sysctl = {
    "net.ipv4.tcp_tw_reuse" => "1",
    "net.ipv4.tcp_syncookies" => "0"
  }
when "ubuntu", "devuan"
  sysctl_conf = "/etc/sysctl.conf"
  sysctl = {
    "net.ipv4.tcp_tw_reuse" => "1",
    "net.ipv4.tcp_syncookies" => "0"
  }
end

sysctl.each do |k, v|
  describe command("#{sysctl_bin} -n '#{k}'") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/^#{Regexp.escape(v)}$/) }
    its(:stderr) { should eq "" }
  end

  describe file(sysctl_conf) do
    it { should be_file }
    its(:content) { should match Regexp.escape("#{k}=#{v}") }
  end
end
