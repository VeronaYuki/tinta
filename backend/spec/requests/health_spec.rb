RSpec.describe "Health" do
  describe "GET /health" do
    context "when every dependency is reachable" do
      it "returns 200" do
        get "/health"

        expect(response).to have_http_status(:ok)
      end

      it "reports each dependency as healthy" do
        get "/health"

        expect(response.parsed_body).to include(
          "status" => "ok",
          "checks" => { "database" => true, "redis" => true }
        )
      end

      it "includes the revision and a timestamp" do
        get "/health"

        expect(response.parsed_body).to include("revision", "timestamp")
      end
    end

    context "when the database is unreachable" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_call_original
        allow(ActiveRecord::Base.connection)
          .to receive(:execute).with("SELECT 1")
          .and_raise(ActiveRecord::ConnectionNotEstablished)
      end

      it "returns 503" do
        get "/health"

        expect(response).to have_http_status(:service_unavailable)
      end

      it "flags the database and leaves the other checks alone" do
        get "/health"

        expect(response.parsed_body).to include(
          "status" => "degraded",
          "checks" => { "database" => false, "redis" => true }
        )
      end
    end

    context "when Redis is unreachable" do
      before do
        allow(REDIS).to receive(:with).and_raise(Redis::CannotConnectError)
      end

      it "returns 503" do
        get "/health"

        expect(response).to have_http_status(:service_unavailable)
      end

      it "flags Redis and leaves the other checks alone" do
        get "/health"

        expect(response.parsed_body).to include(
          "status" => "degraded",
          "checks" => { "database" => true, "redis" => false }
        )
      end
    end
  end
end
