defmodule App.Application do
  use Application

  # The @impl true here denotes that the start function is implementing a
  # callback that was defined in the Application module
  # https://hexdocs.pm/elixir/main/Module.html#module-impl
  # This will aid the compiler to warn you when a implementaion is incorrect
  @impl true
  def start(_type, _args) do
    children = [
      App.DB,
      App.User.Supervisor,
      AppWeb.Endpoint,
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
