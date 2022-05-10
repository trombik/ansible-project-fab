require_relative "../../spec_helper"

describe ENV["TARGET_HOST"] do
  it_behaves_like "slave in a cluster"
  it_behaves_like "master adress is", "192.168.90.100"
end
