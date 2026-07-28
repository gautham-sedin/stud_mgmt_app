redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379")

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    size: ENV.fetch("SIDEKIQ_SERVER_POOL_SIZE", 10).to_i
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    size: ENV.fetch("SIDEKIQ_CLIENT_POOL_SIZE", 5).to_i
  }
end
