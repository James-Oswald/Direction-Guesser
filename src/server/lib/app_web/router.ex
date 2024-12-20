defmodule AppWeb.Router do
  use Plug.Router

  require Logger
 # ---
  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  post "/api/auth" do
    conn
    |> resp_actor(App.Auth)
    |> send_resp()
  end

  post "/api/user" do
    conn
    |> resp_actor({:global, (conn |> get_req_header("x-auth-token") |> Enum.at(0))})
    |> send_resp()
  end

  post "/api/lobby" do
    conn
    |> resp_actor({:global, "l#{GenServer.call({:global, (conn |> get_req_header("x-auth-token") |> Enum.at(0))}, {:lobby_get, %{}}).id}"})
    |> send_resp()
  end

  post "/api/process" do
    conn
    |> resp_actor(App.Process)
    |> send_resp()
  end

  match _ do
    conn
    |> resp(404, "not found")
    |> send_resp()
  end
 # ---
  defp resp_actor(conn, actor) do
    Logger.debug("(router): #{inspect(conn.body_params)}")
    try do
      resp_actor!(conn,actor)
    rescue
      e ->
        Logger.debug("(router): #{inspect(e)}")
        conn
        |> put_resp_content_type("application/json")
        |> resp(500, "#{inspect(e)}")
        reraise e, __STACKTRACE__
    end
  end

  defp resp_actor!(conn, actor) do
    with {:ok, msg}   <- parse_req_msg(conn),
         reply        <- unwrap!(GenServer.call(actor, msg, :infinity))
    do
     Logger.debug("(router): #{inspect(msg)}")
     Logger.debug("(router): #{inspect(reply)}")
     conn
     |> put_resp_content_type("application/json")
     |> resp_j(200, reply)
    else
      e ->
        Logger.debug("(router): #{inspect(e)}")
        conn
        |> put_resp_content_type("application/json")
        |> resp(500, "#{inspect(e)}")
    end
  end

  defp parse_req_msg(conn) do
    case List.first(Map.to_list(conn.body_params)) do
      {op, args} when is_bitstring(op) and is_map(args) ->
        {:ok, {String.to_atom(op), Map.new(Enum.map(args, fn {k, v} -> {String.to_atom(k), v} end))}}
       {op} when is_bitstring(op) ->
        {:ok, {String.to_atom(op)}}
      _ ->
        {:error, :bad_req_msg_format}
    end
  end

  defp unwrap!({:ok,    reply}), do: reply
  defp unwrap!({:error, reply}), do: raise reply
  defp unwrap!(reply          ), do: reply
 # ---
  # NOTE: jason doesn't support encoding Tuples (for reasoning, see:
  # https://github.com/michalmuskala/jason/pull/52). i don't need a
  # decoder because the client will never be trying to send us elixir
  # tuples -ak
  defimpl Jason.Encoder, for: [Tuple] do
    def encode(struct, opts) do
      Jason.Encode.list(Tuple.to_list(struct), opts)
    end
  end

  defp resp_j(conn, http_code, unencoded) do
    try do
      resp(conn, http_code, Jason.encode!(unencoded))
    rescue
      e ->
        resp(conn, 500, Jason.encode!({:error, Exception.message(e)}))
      reraise e, __STACKTRACE__
    end
  end
 # ---
end
