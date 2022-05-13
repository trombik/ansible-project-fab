# frozen_string_literal: true

require_relative "../spec_helper"

describe file "/usr/local/etc/ssl/haproxy" do
  it { should_not exist }
end
