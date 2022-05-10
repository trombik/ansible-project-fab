master_name = "testdb"
password = "password"

shared_examples "responds to PING" do
  describe "redis" do
    let(:redis) do
      Redis.new(
        host: ENV["TARGET_HOST"],
        port: 6379,
        password: password
      )
    end
    it "returns PONG" do
      r = redis.ping
      expect(r).to eq("PONG")
    end
  end
end

shared_examples "master in a cluster" do
  describe "redis-sentinel" do
    let(:redis) do
      Redis.new(
        host: ENV["TARGET_HOST"],
        port: 26_379
      )
    end
    let(:sentinel_master_result) do
      redis.sentinel("master", master_name)
    end

    it "is connected to 2 sentinels" do
      expect(sentinel_master_result["num-other-sentinels"]).to eq("2")
    end

    it "is in the master state" do
      expect(sentinel_master_result["flags"]).to eq("master")
    end

    it "is connected to two slaves" do
      expect(sentinel_master_result["num-slaves"]).to eq("2")
    end
  end
end

shared_examples "slave in a cluster" do
  describe "redis-sentinel" do
    let(:redis) do
      Redis.new(
        host: ENV["TARGET_HOST"],
        port: 26_379
      )
    end
    let(:sentinel_slave_result) do
      redis.sentinel("slaves", master_name)
    end

    it "is in slave state" do
      sentinel_slave_result.each do |s|
        expect(s["role-reported"]).to eq("slave")
        expect(s["flags"]).to eq("slave")
      end
    end
  end
end

shared_examples "master adress is" do |arg|
  describe "redis-sentinel" do
    let(:redis) do
      Redis.new(
        host: ENV["TARGET_HOST"],
        port: 26_379
      )
    end
    let(:sentinel_get_master_result) do
      redis.sentinel("get-master-addr-by-name", master_name)
    end

    it "says master is #{arg}" do
      expect(sentinel_get_master_result).to eq([arg, "6379"])
    end
  end
end

shared_examples "master adress is not" do |arg|
  describe "redis-sentinel" do
    let(:redis) do
      Redis.new(
        host: ENV["TARGET_HOST"],
        port: 26_379
      )
    end
    let(:sentinel_get_master_result) do
      redis.sentinel("get-master-addr-by-name", master_name)
    end

    it "says master is not #{arg}" do
      expect(sentinel_get_master_result).not_to eq([arg, "6379"])
    end
  end
end
