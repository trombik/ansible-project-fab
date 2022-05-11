# frozen_string_literal: true

require_relative "../spec_helper"

describe command "echo" do
  its(:exit_status) { should eq 0 }
end
