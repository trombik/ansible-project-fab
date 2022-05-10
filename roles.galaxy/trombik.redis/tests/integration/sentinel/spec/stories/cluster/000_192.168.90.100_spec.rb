require_relative "../../spec_helper"

describe ENV["TARGET_HOST"] do
  it_behaves_like "responds to PING"
  it_behaves_like "master in a cluster"
  it_behaves_like "master adress is", ENV["TARGET_HOST"]
end
