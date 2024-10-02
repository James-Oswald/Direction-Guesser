defmodule App.User.Supervisor do
  alias App.DB
  alias App.User, as: Child
  alias App.User.Schema, as: User

  def sign_in(attr) do
    User
    |> DB.get_by!(attr)
    |> start_child
  end

  def sign_out(attr) do
    User
    |> DB.get_by!(attr)
    |> terminate_child
  end

  def sign_up(attr) do
    %User{}
    |> User.changeset(attr)
    |> DB.insert()
  end

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp start_child(user) do
    uid = String.to_atom("u#{user.id}")
    spec = { Child, {user, name: uid} }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _pid} ->
        {:ok, uid}
      {:error, {:already_started, _pid}} ->
        {:ok, uid}
    end
  end

  defp terminate_child(user) do
    DynamicSupervisor.terminate_child(__MODULE__, String.to_atom("u#{user.id}"))
  end

end
