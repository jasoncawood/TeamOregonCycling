REQUIRED_ENV_VARS = %w[
TEAMO_HOSTNAME
TEAMO_PORT
TEAMO_DEVISE_SECRET
TEAMO_DEVISE_PEPPER
]

missing = REQUIRED_ENV_VARS - ENV.keys
if missing.any?
  raise "Some required environment variables were not set: #{missing.join(', ')}"
end
