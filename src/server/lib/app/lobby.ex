defmodule App.Lobby do
  use GenServer

  #Starts a new lobby with the given parameters.
  def create_lobby(name, params \\ %{}) do
    defaults = %{
      target_guess_range: "local landmarks",
      time_per_round: 15,
      number_of_rounds: 1
    }
    state = Map.merge(defaults, params)
    GenServer.start_link(__MODULE__, %{name: name, state: state, users: %{}, round_data: []}, name: via_tuple(name))
  end

  #Returns information about the lobby if the calling user is associated with it.
  def get_lobby_info(name, user_pid) do
    GenServer.call(via_tuple(name), {:get_lobby_info, user_pid})
  end

  #Marks the calling user as ready. If all users are ready, starts the round countdown.
  def readyup(name, user_pid) do
    GenServer.call(via_tuple(name), {:readyup, user_pid})
  end

  #Allows a user to join an existing lobby by name.
  def join(name, user_pid) do
    GenServer.call(via_tuple(name), {:join, user_pid})
  end

  #Submits a user's guess for the current round.
  def submit_lobby_guess(name, user_pid, guess_data) do
    GenServer.call(via_tuple(name), {:submit_guess, user_pid, guess_data})
  end

  #GenServer
  def init(%{name: name, state: state, users: users, round_data: round_data}) do
    {:ok, %{name: name, state: state, users: users, round_data: round_data}}
  end

  def handle_call({:get_lobby_info, user_pid}, _from, state) do
    if Map.has_key?(state.users, user_pid) do
      info = %{
        players: Map.keys(state.users),
        num_players: map_size(state.users),
        time_per_round: state.state.time_per_round,
        last_round_scores: state.round_data
      }

      {:reply, {:ok, info}, state}
    else
      {:reply, {:error, "User not associated with this lobby"}, state}
    end
  end

  def handle_call({:join, user_pid}, _from, state) do
    if Map.has_key?(state.users, user_pid) do
      {:reply, {:error, "User already in this lobby"}, state}
    else
      updated_users = Map.put(state.users, user_pid, %{score: nil, ready: false})
      {:reply, {:ok, "Joined lobby"}, %{state | users: updated_users}}
    end
  end

  def handle_call({:readyup, user_pid}, _from, state) do
    if Map.has_key?(state.users, user_pid) do
      updated_users = Map.update!(state.users, user_pid, &Map.put(&1, :ready, true))

      if Enum.all?(updated_users, fn {_pid, %{ready: ready}} -> ready end) do
        Process.send_after(self(), :start_round, 0)
        {:reply, {:ok, "All users ready. Starting round!"}, %{state | users: updated_users}}
      else
        {:reply, {:ok, "User marked as ready"}, %{state | users: updated_users}}
      end
    else
      {:reply, {:error, "User not in this lobby"}, state}
    end
  end

  def handle_call({:submit_guess, user_pid, guess_data}, _from, state) do
    if Map.has_key?(state.users, user_pid) do
      score = App.Process.calculate_score(guess_data)

      updated_users = Map.update!(state.users, user_pid, &Map.put(&1, :score, score))
      {:reply, {:ok, "Guess submitted"}, %{state | users: updated_users}}
    else
      {:reply, {:error, "User not in this lobby"}, state}
    end
  end

  def handle_info(:start_round, state) do
    updated_round_data = Enum.map(state.users, fn {user_pid, %{score: score}} ->
      %{user: user_pid, score: score || 0} # 0 if no guess
    end)

    {:noreply, %{state | round_data: updated_round_data}}
  end

  defp via_tuple(name), do: {:via, Registry, {MyApp.LobbyRegistry, name}}
end
