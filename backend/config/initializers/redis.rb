# Redis client shared by the whole app.
#
# Redis connections are not safe to use from several threads at once, and Puma
# serves requests on many threads — so we hand out connections from a pool, the
# same idea Active Record uses for Postgres. Connections are created lazily, so
# booting with Redis down is fine; only the code that uses it will fail.
#
# Sidekiq (task 5.2) and the cache store (task 8.2) manage their own pools.
REDIS = ConnectionPool.new(size: ENV.fetch("RAILS_MAX_THREADS", 5).to_i, timeout: 1) do
  Redis.new(url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6380/0"), timeout: 1)
end
