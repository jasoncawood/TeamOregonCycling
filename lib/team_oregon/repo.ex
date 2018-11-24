defmodule TeamOregon.Repo do
  use Ecto.Repo,
    otp_app: :team_oregon,
    adapter: Ecto.Adapters.Postgres
end
