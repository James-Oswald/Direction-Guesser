defmodule App.User do
  alias App.DB
  import Ecto.Query, only: [from: 2]

  require Logger

  # @private [:password, :__struct__, :__meta__]
 # ---
  defp lobby_create(user) do
    Logger.info("(#{user.id}): creating lobby")
    with lobby
            <- %App.Lobby.Schema{} |> DB.insert!(),
         {:ok, {:global, lobby_id}}
            <- App.Supervisor.Lobbies.start_lobby(lobby) do
      Logger.info("(u#{user.id}): created lobby (#{lobby_id})")
      lobby_id
    end
  end

  defp lobby_join(user, lobby_id) do
    Logger.info("(u#{user.id}): joining lobby (#{lobby_id})")
    GenServer.call({:global, lobby_id}, {:join, "u#{user.id}"})
  end

  defp lobby_ready(user, user_lat, user_lon) do
    lobby = lobby_get(user)
    GenServer.call({:global, "l#{lobby.id}"}, {:readyup, "u#{user.id}", user_lat, user_lon})
  end

  defp lobby_submit(user, guess_data) do
    lobby = lobby_get(user)
    GenServer.call({:global, "l#{lobby.id}"}, {:submit, "u#{user.id}", guess_data})
  end

  defp lobby_get(user) do
    App.DB.all(App.Lobby.Schema) |> Enum.reverse() |> Enum.filter(fn lobby -> lobby.users |> Map.has_key?("u#{user.id}") end) |> List.first
  end
 # ---
  use GenServer

  def start_link(user) do
    GenServer.start_link(__MODULE__, user, name: {:global, "u#{user.id}"})
  end

  def stop(reason, user) do
    Logger.info("(u#{user.id}): logged out (#{reason})")
    {:ok, user}
  end

  @impl true
  def init(user) do
    Logger.info("(u#{user.id}): logged in")
    {:ok, user}
  end

  @impl true
  def handle_call({:lobby_create, _}, _from, state) do
    Logger.info("(u#{state.id}): creating lobby")
    {:reply, lobby_create(state), state}
  end

  @impl true
  def handle_call({:lobby_join, %{id: id}}, _from, state) do
    Logger.info("(u#{state.id}): joining lobby #{id}")
    {:reply, lobby_join(state, id), state}
  end

  @impl true
  def handle_call({:lobby_ready, %{user_lat: user_lat, user_lon: user_lon}}, _from, state) do
    Logger.info("(u#{state.id}): readying up")
    {:reply, lobby_ready(state, user_lat, user_lon), state}
  end

  @impl true
  def handle_call({:lobby_submit, guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _}}, _from, state) do
    Logger.info("(u#{state.id}): submitting guess #{guess_data}")
    {:reply, lobby_submit(state, guess_data), state}
  end

  @impl true
  def handle_call({:lobby_get, _}, _from, state) do
    {:reply, lobby_get(state), state}
  end
 # ---
end
