require_relative "../../spec_helper"

context "when master redis is down" do
  describe command "service redis stop" do
    its(:exit_status) { should eq 0 }
  end

  describe command "sleep 20" do
    its(:exit_status) { should eq 0 }
  end

  describe ENV["TARGET_HOST"] do
    sleep 10
    it_behaves_like "master adress is not", "192.168.90.100"
  end
end
