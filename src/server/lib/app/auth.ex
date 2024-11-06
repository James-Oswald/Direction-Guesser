defmodule App.Auth do
  alias App.DB
  alias App.User
  alias App.User.Schema

  defp sign_in(attr = %{username: _, password: _}) do
    Schema
    |> DB.get_by!(attr)
    |> User.start_child
  end

  defp sign_out(uid) when is_number(uid) do
    Schema
    |> DB.get_by!(%{id: uid})
    |> User.terminate_child
  end

  defp sign_up(attr) when is_list(attr) do
    sign_up(Enum.into(attr, %{}))
  end
  defp sign_up(attr) when is_map(attr) do
    %Schema{}
    |> Schema.changeset(attr)
    |> DB.insert()
  end

  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call([:sign_in, attr = %{username: _, password: _}], _from, state) do
    {:reply, sign_in(attr), state}
  end

  @impl true
  def handle_call([:sign_out, sid], _from, state) do
    {:reply, sign_out(sid), state}
  end

  @impl true
  def handle_call([:sign_up, attr], _from, state) do
    {:reply, sign_up(attr), state}
  end
end
