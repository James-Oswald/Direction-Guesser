defmodule App.Lobby do
  alias App.DB
  alias App.Lobby

  require Logger
  # ---
  def user_get({_pid, user_data}, slot_name) when is_map(user_data) do
    Map.get(user_data, slot_name) || Map.get(user_data, String.to_atom(slot_name))
  end

  defp all_users_ready?(users) do
    Enum.all?(users, fn user -> user_get(user, "ready") end)
  end

  defp all_users_guessed?(users) do
    Enum.all?(users, fn user -> user_get(user, "score") end)
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
  def readyup(lobby, user_pid, user_data = %{user_lat: user_lat, user_lon: user_lon}, from) do
    lobby =
      Lobby.Schema |> DB.get_by!(%{id: lobby.id})

      if lobby.location == nil do
    random_city =
      GenServer.call(
          App.Process,
          {:calculate_nearby, %{user_lat: user_lat, user_lon: user_lon, range: 20}}
        )
      DB.update!(Ecto.Changeset.change(lobby, %{location: Jason.encode!(random_city)}))
    end

      lobby =
        Lobby.Schema |> DB.get_by!(%{id: lobby.id})

    if Map.has_key?(lobby.users, user_pid) do
      updated_users =
        Map.put(lobby.users, user_pid, %{lobby.users[user_pid] | "ready" => true})
      DB.update!(Ecto.Changeset.change(lobby, %{users: updated_users}))

      if all_users_ready?(updated_users) do
        GenServer.reply(from, {:ok, lobby.location})
      else
        Logger.info("(l#{lobby.id}): waiting on other users to ready up #{inspect(lobby)}")
        Logger.info("(l#{lobby.id}): this is user #{inspect(user_pid)}")
        Process.sleep(500)
        readyup(lobby, user_pid, user_data, from)
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
      user =
        GenServer.call({:global, user_pid}, {:get, {}})
      updated_users =
        Map.put(lobby.users, user_pid, %{username: user.username, location: nil, score: nil, ready: false})

      DB.update!(Ecto.Changeset.change(lobby, %{users: updated_users}))
      :ok
    end
  end

  def submit_guess(
        lobby,
        user_pid,
        guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _},
        from
      ) do
    lobby =
      Lobby.Schema |> DB.get_by!(%{id: lobby.id})

    if Map.has_key?(lobby.users, user_pid) do
      score =
        GenServer.call(App.Process, {:calculate_score, guess_data})

      updated_users =
        Map.update!(lobby.users, user_pid, &Map.put(&1, :score, score))

      DB.update!(Ecto.Changeset.change(lobby, %{users: updated_users}))

      if all_users_guessed?(updated_users) do
        GenServer.reply(from, {:ok, score})
      else
        Process.sleep(500)
        submit_guess(lobby, user_pid, guess_data,from)
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
  def handle_call({:readyup, user_pid, user_data = %{user_lat: _, user_lon: _}}, from, lobby) do
    Logger.info("(l#{lobby.id}): hello this is user #{inspect(user_pid)}")
    spawn(Lobby, :readyup, [lobby, user_pid, user_data, from])
    {:noreply, lobby}
    # {:reply, readyup(lobby, user_pid, user_data), lobby}
  end

  @impl true
  def handle_call(
        {:submit_guess, user_pid,
         guess_data = %{user_bearing: _, user_lat: _, user_lon: _, target_lat: _, target_lon: _}},
        from,
        lobby
      ) do
        spawn(Lobby, :submit_guess, [lobby, user_pid, guess_data, from])
        {:noreply, lobby}
  end
end
