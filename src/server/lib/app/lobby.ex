defmodule App.Lobby do
  alias App.DB
  alias App.Lobby
  
  require Logger
 # ---    
  defp all_users_ready?(users) do
    Enum.all?(users, fn {_pid, %{ready: ready}} -> ready end)
  end

  defp all_users_guessed?(users) do
    Enum.all?(users, fn {_pid, %{ score: score}} -> score end)
  end
 # ---    
  def get_lobby_info(lobby, user_pid) do
    lobby =
      Lobby.Schema |> DB.get_by!(%{id: lobby.id})
    if Map.has_key?(lobby.users, user_pid) do
      info = %{
        players: Map.keys(lobby.users),
        num_players: map_size(lobby.users),
        time_per_round: lobby.time_per_round,
        last_round_scores: lobby.round_data
      }
      {:ok, info}
    else
      {:error, "User not associated with this lobby"}
    end
  end

  # FIXME: we should be passing the lobby_id around, not the
  # lobby. this will enforce the fact that we have up to date data.
  def readyup(lobby, user_pid, user_data = %{user_lat: user_lat, user_lon: user_lon}) do
    lobby =
      Lobby.Schema |> DB.get_by!(%{id: lobby.id})
    if Map.has_key?(lobby.users, user_pid) do
      updated_users =
	Map.update!(lobby.users, user_pid, &Map.put(&1, :ready, true))
      if all_users_ready?(updated_users) do
	random_city = 
	  GenServer.call(App.Process, {:calculate_nearby, %{user_lat: user_lat, user_lon: user_lon, range: 20}})
	{:ok, random_city}
      else
	Process.sleep(500)
	readyup(lobby, user_pid, user_data)
      end
    else
      {:error, "User not in this lobby"}
    end
  end

  def join(lobby, user_pid) do
    lobby =
      Lobby.Schema |> DB.get_by!(%{id: lobby.id})
    if Map.has_key?(lobby.users, user_pid) do
      {:error, "User already in this lobby"}
    else
      updated_users =
	Map.put(lobby.users, user_pid, %{score: nil, ready: false})
      DB.update!(Ecto.Changeset.change(lobby, %{users: updated_users}))
      :ok
    end
  end
  
    @impl true
  def submit_guess(lobby, user_pid, guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _}) do
      lobby =
	Lobby.Schema |> DB.get_by!(%{id: lobby.id})
      if Map.has_key?(lobby.users, user_pid) do
	score =
	  GenServer.call(App.Process, {:calculate_score, guess_data})
	updated_users =
	  Map.update!(lobby.users, user_pid, &Map.put(&1, :score, score))
	DB.update!(Ecto.Changeset.change(lobby, %{users: updated_users}))
	
	if all_users_guessed?(updated_users) do
	  {:ok, score}
	else
          Process.sleep(500)
          submit_guess(lobby,user_pid, guess_data)
	end	
      else
	{:error, "User not in this lobby"}
      end
    end
 # ---
  use GenServer
  require Logger

  def start_link(lobby) do
    GenServer.start_link(__MODULE__, lobby, name: {:global, "l#{lobby.id}"})
  end

  @impl true
  def init(lobby) do
    Logger.info("(l#{lobby.id}): created")
    {:ok, lobby}
  end

  @impl true
  def handle_call({:get_lobby_info, user_pid}, _from, lobby) do
      {:reply, get_lobby_info(lobby, user_pid), lobby}
  end

  @impl true
  def handle_call({:join, user_pid}, _from, lobby) do
    {:reply, join(lobby, user_pid), lobby}
  end

  @impl true
  def handle_call({:readyup, user_pid, user_data = %{user_lat: _, user_lon: _}}, _from, lobby) do
    {:reply, readyup(lobby, user_pid, user_data), lobby}
  end

  @impl true
  def handle_call({:submit_guess, user_pid, guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _}}, _from, lobby) do
    {:reply, submit_guess(lobby, user_pid, guess_data), lobby}
  end
end
