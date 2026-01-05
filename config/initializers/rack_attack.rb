# frozen_string_literal: true

# Rate limiting configuration using Rack::Attack
# Protects the API from abuse, especially the view count endpoint

class Rack::Attack
  # Use Rails cache for tracking
  Rack::Attack.cache.store = Rails.cache

  # Throttle view count increments: 10 requests per minute per IP per post
  # This prevents someone from spamming the view counter
  throttle("increment_view/ip/post", limit: 10, period: 1.minute) do |req|
    if req.path =~ %r{/posts/\d+/increment_view} && req.post?
      # Use IP + post ID as the discriminator
      post_id = req.path.match(%r{/posts/(\d+)/increment_view})[1]
      "#{req.ip}:#{post_id}"
    end
  end

  # Throttle all requests by IP: 300 requests per 5 minutes
  # General protection against aggressive clients
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Block suspicious requests
  blocklist("block bad user agents") do |req|
    # Block requests with no user agent (often bots)
    # But allow internal/health check requests
    req.user_agent.blank? && !req.path.start_with?("/up")
  end

  # Custom response for rate-limited requests
  self.throttled_responder = lambda do |req|
    [
      429,
      { "Content-Type" => "application/json" },
      [{ error: "Rate limit exceeded. Please try again later." }.to_json]
    ]
  end
end
