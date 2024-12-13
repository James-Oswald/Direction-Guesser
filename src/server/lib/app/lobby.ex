defmodule App.Lobby do
  use GenServer

  require Logger

  #Returns information about the lobby if the calling user is associated with it.
  def get_lobby_info(lobby_id, user_pid) do
    GenServer.call({:global, lobby_id}, {:get_lobby_info, user_pid})
  end

  #Marks the calling user as ready. If all users are ready, starts the round countdown.
  def readyup(lobby_id, user_pid) do
    GenServer.call({:global, lobby_id}, {:readyup, user_pid})
  end

  #Allows a user to join an existing lobby by lobby_id.
  def join(lobby_id, user_pid) do
    GenServer.call({:global, lobby_id}, {:join, user_pid})
  end

  #Submits a user's guess for the current round.
  def submit_lobby_guess(lobby_id, user_pid, guess_data) do
    GenServer.call({:global, lobby_id}, {:submit_guess, user_pid, guess_data})
  end

  #GenServer
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
    if Map.has_key?(lobby.users, user_pid) do
      info = %{
        players: Map.keys(lobby.users),
        num_players: map_size(lobby.users),
        time_per_round: lobby.time_per_round,
        last_round_scores: lobby.round_data
      }

      {:reply, {:ok, info}, lobby}
    else
      {:reply, {:error, "User not associated with this lobby"}, lobby}
    end
  end

  @impl true
  def handle_call({:join, user_pid}, _from, lobby) do
    if Map.has_key?(lobby.users, user_pid) do
      {:reply, {:error, "User already in this lobby"}, lobby}
    else
      updated_users = Map.put(lobby.users, user_pid, %{score: nil, ready: false})
      {:reply, :ok, %{lobby | users: updated_users}}
    end
  end

  @impl true
  def handle_call({:readyup, user_pid}, _from, lobby) do
    if Map.has_key?(lobby.users, user_pid) do
      updated_users = Map.update!(lobby.users, user_pid, &Map.put(&1, :ready, true))

      if all_users_ready?(updated_users) do
        Process.send_after(self(), :start_round, lobby.time_per_round * 1000)
        {:reply, {:ok, "All users ready. Starting round!"}, %{lobby | users: updated_users}}
      else
        {:reply, {:ok, "User marked as ready"}, %{lobby | users: updated_users}}
      end
    else
      {:reply, {:error, "User not in this lobby"}, lobby}
    end
  end

  @impl true
  def handle_call({:submit_guess, user_pid, guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _}}, _from, lobby) do
    if Map.has_key?(lobby.users, user_pid) do
      score = GenServer.call(App.Process, {:calculate_score, guess_data})

      updated_users = Map.update!(lobby.users, user_pid, &Map.put(&1, :score, score))
      {:reply, {:ok, "Guess submitted"}, %{lobby | users: updated_users}}
    else
      {:reply, {:error, "User not in this lobby"}, lobby}
    end
  end

  @impl true
  def handle_info(:start_round, lobby) do
    updated_round_data = Enum.map(lobby.users, fn {user_pid, %{score: score}} ->
      %{user: user_pid, score: score || 0} #0 if no guess
    end)

    {:noreply, %{lobby | round_data: updated_round_data}}
  end

  #aux func
  defp all_users_ready?(users) do
    Enum.all?(users, fn {_pid, %{ready: ready}} -> ready end)
  end
end
