class HealthController < ApplicationController
  # Unlike Rails' built-in /up (which only proves the app booted), this
  # endpoint checks critical dependencies and returns 503 when one is down,
  # so uptime monitors and load balancers can tell "process alive" from
  # "actually able to serve requests".
  def show
    checks = { database: database_ok?, redis: redis_ok? }
    healthy = checks.values.all?

    render json: {
      status: healthy ? "ok" : "degraded",
      checks: checks,
      revision: ENV.fetch("GIT_COMMIT_SHA", "unknown"),
      timestamp: Time.current.iso8601
    }, status: healthy ? :ok : :service_unavailable
  end

  private

  def database_ok?
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue StandardError
    false
  end

  # PING/PONG is Redis' equivalent of SELECT 1: the cheapest possible proof
  # that the server is reachable and answering.
  def redis_ok?
    REDIS.with { |redis| redis.ping == "PONG" }
  rescue StandardError
    false
  end
end
