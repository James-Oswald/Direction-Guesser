defmodule App.User do
  require Logger

  @private [:password, :__struct__, :__meta__]
 # ---
  use GenServer

  def start_link(user) do
    GenServer.start_link(__MODULE__, user, name: {:global, user.id})
  end

  def stop(reason, user) do
    Logger.info("(#{user.id}): logged out (#{reason})")
    {:ok, user}
  end

  @impl true
  def init(user) do
    Logger.info("(#{user.id}): logged in")
    {:ok, user}
  end
 # ---
end
