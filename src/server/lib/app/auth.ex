defmodule App.Auth do
  alias App.DB
  alias App.User
  alias App.User.Schema

  def sign_in(attr) do
    Schema
    |> DB.get_by!(attr)
    |> User.start_child
  end

  def sign_out(attr) do
    Schema
    |> DB.get_by!(attr)
    |> User.terminate_child
  end

  def sign_up(attr) do
    %Schema{}
    |> Schema.changeset(Enum.into(attr, %{}))
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
  def handle_call({:sign_in, attr}, _from, state) do
    {:reply, sign_in(attr), state}
  end

  @impl true
  def handle_call({:sign_out, attr}, _from, state) do
    {:reply, sign_out(attr), state}
  end

  @impl true
  def handle_call({:sign_up, attr}, _from, state) do
    {:reply, sign_up(attr), state}
  end
end
