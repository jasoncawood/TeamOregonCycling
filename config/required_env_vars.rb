unless defined?(REQUIRED_ENV_VARS)
  REQUIRED_ENV_VARS = %w[
    TEAMO_HOSTNAME
    TEAMO_PORT
    TEAMO_DEVISE_SECRET
    TEAMO_DEVISE_PEPPER
  ]
end

missing = REQUIRED_ENV_VARS - ENV.keys
if missing.any?
  raise "Some required environment variables were not set: #{missing.join(', ')}"
end
