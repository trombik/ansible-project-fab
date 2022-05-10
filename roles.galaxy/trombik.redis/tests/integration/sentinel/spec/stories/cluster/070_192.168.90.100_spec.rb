require_relative "../../spec_helper"

describe command "service redis start" do
  its(:exit_status) { should eq 0 }
end

describe command "sleep 20" do
  its(:exit_status) { should eq 0 }
end

context "when the original master is back" do
  describe ENV["TARGET_HOST"] do
    let(:redis) do
      Redis.new(
        host: ENV["TARGET_HOST"],
        port: 6379,
        password: "password"
      )
    end

    it_behaves_like "master adress is not", "192.168.90.100"
    it_behaves_like "slave in a cluster"

    it "should return buz that has been set while it was down" do
      r = redis.get("foo")
      expect(r).to eq("buz")
    end
  end
end
