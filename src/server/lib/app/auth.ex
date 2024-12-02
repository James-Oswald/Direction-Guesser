defmodule App.Auth do
  alias App.DB
  alias App.User
  alias App.Supervisor.Users

  require Logger
 # ---
  defp sign_in(opts = %{username: _, password: _}) do
    Logger.debug("(auth): signing in #{inspect(opts)}")
    User.Schema
    |> DB.get_by!(opts)
    |> Users.start_user
  end

  defp sign_out(opts = %{username: _, password: _}) do
    Logger.debug("(auth): signing out #{inspect(opts)}")
    User.Schema
    |> DB.get_by!(opts)
    |> Users.stop_user
  end

  defp sign_up(opts) do
    Logger.debug("(auth): signing up #{inspect(opts)}")
    open_user(opts) |> DB.insert!()
  end

  defp open_user(opts), do: %User.Schema{} |> User.Schema.changeset(opts)
 # ---
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.info("(auth): started #{inspect(state)}")
    {:ok, state}
  end

  @impl true
  def handle_call({:sign_in, opts}, _from, state) do
    {:reply, sign_in(opts), state}
  end

  @impl true
  def handle_call({:sign_out, opts}, _from, state) do
    {:reply, sign_out(opts), state}
  end

  @impl true
  def handle_call({:sign_up, opts}, _from, state) do
    {:reply, sign_up(opts), state}
  end
 # ---
end
