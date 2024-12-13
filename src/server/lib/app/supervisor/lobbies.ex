defmodule App.Supervisor.Lobbies do
  alias App.Lobby

  require Logger

  use DynamicSupervisor

  def start_lobby(name, params \\ %{}) do
    case DynamicSupervisor.start_child(__MODULE__, {Lobby, %{name: name, params: params}}) do
      {:ok, _pid} ->
        {:ok, {:global, name}}
      {:error, {:already_started, _pid}} ->
        {:ok, {:global, name}}
    end
  end

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop_lobby(name) do
    DynamicSupervisor.terminate_child(__MODULE__, {:global, name})
  end

  @impl true
  def init(state) do
    Logger.info("(lobbies): started #{inspect(state)}")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end