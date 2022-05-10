require_relative "../../spec_helper"

context "when master redis is down" do
  describe ENV["TARGET_HOST"] do
    it_behaves_like "master adress is not", "192.168.90.100"
  end
end
