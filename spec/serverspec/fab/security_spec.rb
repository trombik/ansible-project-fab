# frozen_string_literal: true

require_relative "../spec_helper"

describe "haproxy ACLs" do
  ["http", "https"].each do |scheme|
    describe command "curl --verbose --insecure --header 'Host: nosuch.host.mkrsgh.org' #{scheme.shellescape}://127.0.0.1/" do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/#{Regexp.escape("HTTP/1.1 403")}/) }
    end

    describe command "curl --verbose --insecure --header 'Host: fab.mkrsgh.org' --http1.0 #{scheme.shellescape}://127.0.0.1/" do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/#{Regexp.escape("HTTP/1.1 403")}/) }
    end
  end
end
