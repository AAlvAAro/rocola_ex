defmodule Rocola.Repo do
  use Ecto.Repo,
    otp_app: :rocola,
    adapter: Ecto.Adapters.SQLite3
end
