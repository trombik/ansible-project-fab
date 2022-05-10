require "spec_helper"
require "serverspec"
require "yaml"

package = case os[:family]
          when "freebsd"
            "lang/ruby27"
          else
            "ruby"
          end

describe package(package) do
  it { should be_installed }
end

describe command("ruby --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^ruby \d+\.\d+\.\d+/) }
  its(:stderr) { should eq("") }
end

describe command("gem --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^\d+\.\d+\.\d+/) }
  its(:stderr) { should eq("") }
end

describe command("bundler --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Bundler version \d+.\d+.\d+/) }
  its(:stderr) { should eq("") }
end
