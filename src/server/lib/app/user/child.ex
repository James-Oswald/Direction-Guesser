defmodule App.User.Child do
  use GenServer
  require Logger

  @private [:password, :__struct__, :__meta__]

  def start_link({user, opts}) do
    GenServer.start_link(__MODULE__, user, opts)
  end

  def stop(reason, user) do
    Logger.info("u#{user.id} (#{user.username}): logged out (#{reason})")
    {:ok, user}
  end

  @impl true
  def init(user) do
    Logger.info("u#{user.id} (#{user.username}): logged in")
    {:ok, user}
  end

  @impl true
  def handle_call([:get], _from, user) do
    {:reply, {:ok, Map.drop(user, @private)}, user}
  end

  @impl true
  def handle_call([:proxy, actor, msg | msg_opts], _from, user) do
    if (actor == String.to_atom("u#{user.id}")) do
      handle_call([msg | msg_opts], _from, user)
    else
      GenServer.call(actor, [msg | msg_opts])
    end
  end
end
