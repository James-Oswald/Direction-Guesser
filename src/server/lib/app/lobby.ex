defmodule App.Lobby do
  use GenServer
  alias App.DB

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
      DB.update!(Ecto.Changeset.change(lobby, %{users: updated_users}))

      {:reply, :ok, %{lobby | users: updated_users}}
    end
  end

  @impl true
  def handle_call({:readyup, user_pid}, _from, lobby) do
    lobby = Lobby.Schema |> DB.get_by!(%{id: lobby.id})
    if Map.has_key?(lobby.users, user_pid) do
      updated_users = Map.update!(lobby.users, user_pid, &Map.put(&1, :ready, true))
      DB.update!(Ecto.Changeset.change(lobby, %{users: updated_users}))

      if all_users_ready?(updated_users) do
        {:reply, GenServer.call(App.Process, {:calculate_nearby, %{user_lat: 42.687, user_lon: -73.824, range: 20}}), %{lobby | users: updated_users}}
      else
        Process.sleep(500)
        GenServer.call(Kernel.self(), {:readyup, user_pid})
      end
    else
      {:reply, {:error, "User not in this lobby"}, lobby}
    end
  end

  @impl true
  def handle_call({:submit_guess, user_pid, guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _}}, _from, lobby) do
    lobby = Lobby.Schema |> DB.get_by!(%{id: lobby.id})
    if Map.has_key?(lobby.users, user_pid) do
      score = GenServer.call(App.Process, {:calculate_score, guess_data})
      updated_users = Map.update!(lobby.users, user_pid, &Map.put(&1, :score, score))
      DB.update!(Ecto.Changeset.change(lobby, %{users: updated_users}))

      if all_users_guessed?(updated_users) do
        {:reply, GenServer.call(App.Process, {:calculate_score, guess_data}), %{lobby | users: updated_users}}
      else
        Process.sleep(500)
        GenServer.call(Kernel.self(), {:submit_guess, user_pid, guess_data})
      end


    else
      {:reply, {:error, "User not in this lobby"}, lobby}
    end
  end

  @impl true
  def handle_info(:start_round, lobby) do
    updated_round_data = Enum.map(lobby.users, fn {user_pid, %{score: score}} ->
      %{user: user_pid, score: score || 0} #0 if no guess
    end)
    DB.update!(Ecto.Changeset.change(lobby, %{ round_data: updated_round_data}))
    {:noreply, %{lobby | round_data: updated_round_data}}
  end

  #aux func
  defp all_users_ready?(users) do
    Enum.all?(users, fn {_pid, %{ready: ready}} -> ready end)
  end

  defp all_users_guessed?(users) do
    Enum.all?(users, fn {_pid, %{ score: score}} -> score end)
  end

end
