defmodule App.Lobby do
  use GenServer

  require Logger

  #Starts a new lobby with the given parameters.
  def start_link(%{name: name} = args) do
    :global.register_name(name, GenServer.start_link(__MODULE__, args))
  end

  #Returns information about the lobby if the calling user is associated with it.
  def get_lobby_info(name, user_pid) do
    GenServer.call({:global, name}, {:get_lobby_info, user_pid})
  end

  #Marks the calling user as ready. If all users are ready, starts the round countdown.
  def readyup(name, user_pid) do
    GenServer.call({:global, name}, {:readyup, user_pid})
  end

  #Allows a user to join an existing lobby by name.
  def join(name, user_pid) do
    GenServer.call({:global, name}, {:join, user_pid})
  end

  #Submits a user's guess for the current round.
  def submit_lobby_guess(name, user_pid, guess_data) do
    GenServer.call({:global, name}, {:submit_guess, user_pid, guess_data})
  end

  #GenServer
  @impl true
  def init(%{name: name, params: params}) do
    defaults = %{
      target_guess_range: "local landmarks",
      time_per_round: 15,
      number_of_rounds: 1
    }

    state = Map.merge(defaults, params)
    {:ok, %{name: name, state: state, users: %{}, round_data: []}}
  end

  @impl true
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

  @impl true
  def handle_call({:join, user_pid}, _from, state) do
    if Map.has_key?(state.users, user_pid) do
      {:reply, {:error, "User already in this lobby"}, state}
    else
      updated_users = Map.put(state.users, user_pid, %{score: nil, ready: false})
      {:reply, :ok, %{state | users: updated_users}}
    end
  end

  @impl true
  def handle_call({:readyup, user_pid}, _from, state) do
    if Map.has_key?(state.users, user_pid) do
      updated_users = Map.update!(state.users, user_pid, &Map.put(&1, :ready, true))

      if all_users_ready?(updated_users) do
        Process.send_after(self(), :start_round, state.state.time_per_round * 1000)
        {:reply, {:ok, "All users ready. Starting round!"}, %{state | users: updated_users}}
      else
        {:reply, {:ok, "User marked as ready"}, %{state | users: updated_users}}
      end
    else
      {:reply, {:error, "User not in this lobby"}, state}
    end
  end

  @impl true
  def handle_call({:submit_guess, user_pid, guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _}}, _from, state) do
    if Map.has_key?(state.users, user_pid) do
      score = GenServer.call(App.Process, {:calculate_score, guess_data})

      updated_users = Map.update!(state.users, user_pid, &Map.put(&1, :score, score))
      {:reply, {:ok, "Guess submitted"}, %{state | users: updated_users}}
    else
      {:reply, {:error, "User not in this lobby"}, state}
    end
  end

  @impl true
  def handle_info(:start_round, state) do
    updated_round_data = Enum.map(state.users, fn {user_pid, %{score: score}} ->
      %{user: user_pid, score: score || 0} #0 if no guess
    end)

    {:noreply, %{state | round_data: updated_round_data}}
  end

  #aux func
  defp all_users_ready?(users) do
    Enum.all?(users, fn {_pid, %{ready: ready}} -> ready end)
  end
end
