defmodule AppWeb.Endpoint do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children = [
      { Plug.Cowboy,
        scheme: :http,
        plug: AppWeb.Router,
        options: [port: Application.fetch_env!(:app, :port)] }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
