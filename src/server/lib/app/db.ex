defmodule App.DB do
  use Ecto.Repo,
    otp_app: :app,
    adapter: Ecto.Adapters.SQLite3
end
