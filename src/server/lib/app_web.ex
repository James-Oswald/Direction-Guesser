defmodule AppWeb do
  def route do
    quote do
      use Plug.Router

      plug Plug.Logger
      plug :match
      plug Plug.Parsers, parsers: [:json], json_decoder: Jason
      plug :dispatch
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
