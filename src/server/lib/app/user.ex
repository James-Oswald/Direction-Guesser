defmodule App.User do
  alias App.User.Child

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(user) do
    uid = String.to_atom("u#{user.id}")
    spec = { Child, {user, name: uid} }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _pid} ->
        {:ok, uid}
      {:error, {:already_started, _pid}} ->
        {:ok, uid}
    end
  end

  def terminate_child(user) do
    DynamicSupervisor.terminate_child(__MODULE__, String.to_atom("u#{user.id}"))
  end
end
