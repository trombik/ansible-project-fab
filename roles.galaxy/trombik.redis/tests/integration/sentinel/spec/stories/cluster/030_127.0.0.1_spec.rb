require_relative "../../spec_helper"

master = ["192.168.90.100"]
slaves = ["192.168.90.201", "192.168.90.202"]
all_nodes = master + slaves
password = "password"
master_name = "testdb"

context "when client has sentinel support" do
  describe "the cluster" do
    let(:url) { "redis://#{master_name}" }
    let(:sentinels) do
      all_nodes.map { |n| { host: n, port: 26_379 } }
    end
    let(:redis_master) do
      Redis.new(
        url: url,
        sentinels: sentinels,
        password: password,
        role: :master
      )
    end
    let(:redis_slave) do
      Redis.new(
        url: url,
        sentinels: sentinels,
        password: password,
        role: :slave
      )
    end

    describe "master" do
      it "should accept set request" do
        r = redis_master.set("foo", "bar")
        expect(r).to eq("OK")
      end
    end

    describe "slaves" do
      it "should return bar" do
        r = redis_slave.get("foo")
        expect(r).to eq("bar")
      end
    end
  end
end
