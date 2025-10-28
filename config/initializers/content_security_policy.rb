# Be sure to restart your server when you modify this file.

# Completely disable Content Security Policy for this vulnerable application
# This allows Swagger UI and all other connections to work without restrictions

# Set CSP to allow everything (effectively disabling it)
Rails.application.config.content_security_policy do |policy|
  # Allow everything from any source
  policy.default_src :self, :https, :http, :unsafe_inline, :unsafe_eval, :data, :blob, :wss, :ws, '*'
  policy.connect_src :self, :https, :http, :ws, :wss, '*'
end

# Disable nonce generation
Rails.application.config.content_security_policy_nonce_generator = nil
Rails.application.config.content_security_policy_nonce_directives = []

# Don't use report-only mode
Rails.application.config.content_security_policy_report_only = false

