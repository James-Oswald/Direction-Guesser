defmodule App.Supervisor.Users do
  alias App.User

  require Logger
 # ---
  use DynamicSupervisor

  def start_user(user) do
    case DynamicSupervisor.start_child(__MODULE__, {User, user}) do
      {:ok, _pid} ->
        {:ok, {:global, user.id}}
      {:error, {:already_started, _pid}} ->
        {:ok, {:global, user.id}}
    end
  end

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop_user(user) do
    DynamicSupervisor.terminate_child(__MODULE__, {:global, user.id})
  end

  @impl true
  def init(state) do
    Logger.info("(users): started #{inspect(state)}")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
 # ---
end
