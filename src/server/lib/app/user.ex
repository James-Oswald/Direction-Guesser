defmodule App.User do
  alias App.DB
  alias App.User

  require Logger

  # @private [:password, :__struct__, :__meta__]
 # ---
  def get(user, from) do
    GenServer.reply(from, user)
  end
 # ---
  def lobby_create(user, from) do
    Logger.info("(#{user.id}): creating lobby")
    with lobby
            <- %App.Lobby.Schema{} |> DB.insert!(),
         {:ok, lobby_id}
            <- App.Supervisor.Lobbies.start_lobby(lobby) do
      Logger.info("(u#{user.id}): created lobby (#{lobby_id})")
      GenServer.reply(from, lobby_id)
    else
	e -> GenServer.reply(from, {:error, "failed to create lobby #{inspect(e)}"})
    end
  end

  def lobby_join(user, lobby_id, from) do
    Logger.info("(u#{user.id}): joining lobby (#{lobby_id})")
    GenServer.reply(from, GenServer.call({:global, lobby_id}, {:join, "u#{user.id}"}))
  end

  def lobby_ready(user, user_data = %{user_lat: _, user_lon: _}, from) do
    lobby = lobby_get(user)
    Logger.info("(u#{user.id}): #{inspect({:readyup, "u#{user.id}", user_data})}")
    GenServer.reply(from, GenServer.call({:global, "l#{lobby.id}"}, {:readyup, "u#{user.id}", user_data}, :infinity))
  end

  def lobby_submit(user, guess_data, from) do
    lobby = lobby_get(user)
    GenServer.reply(from, GenServer.call({:global, "l#{lobby.id}"}, {:submit_guess, "u#{user.id}", guess_data}, :infinity))
  end

  def lobby_get(user) do
    App.DB.all(App.Lobby.Schema) |> Enum.reverse() |> Enum.filter(fn lobby -> lobby.users |> Map.has_key?("u#{user.id}") end) |> List.first
  end
  def lobby_get(user, from) do
    GenServer.reply(from, App.DB.all(App.Lobby.Schema) |> Enum.reverse() |> Enum.filter(fn lobby -> lobby.users |> Map.has_key?("u#{user.id}") end) |> List.first)
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
  def handle_call({:get, _}, from, state) do
    spawn(User, :get, [state, from])
    {:noreply, state}
  end

  @impl true
  def handle_call({:lobby_create, _}, from, state) do
    Logger.info("(u#{state.id}): creating lobby")
    spawn(User, :lobby_create, [state, from])
    {:noreply, state}
  end

  @impl true
  def handle_call({:lobby_join, %{id: id}}, from, state) do
    Logger.info("(u#{state.id}): joining lobby #{id}")
    spawn(User, :lobby_join, [state, id, from])
    {:noreply, state}
  end

  @impl true
  def handle_call({:lobby_ready, user_data = %{user_lat: _, user_lon: _}}, from, state) do
    Logger.info("(u#{state.id}): readying up")
    spawn(User, :lobby_ready, [state, user_data, from])
    {:noreply, state}
  end

  @impl true
  def handle_call({:lobby_submit, guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _}}, from, state) do
    Logger.info("(u#{state.id}): submitting guess #{inspect(guess_data)}")
    spawn(User, :lobby_submit, [state, guess_data, from])
    {:noreply, state}
  end

  @impl true
  def handle_call({:lobby_get, _}, from, state) do
    spawn(User, :lobby_get, [state, from])
    {:noreply, state}
  end
 # ---
end
