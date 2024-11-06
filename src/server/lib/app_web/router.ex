defmodule AppWeb.Router do
  use Plug.Router

#
  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  require Logger

  post "/api/auth" do
    conn
    |> resp_actor(App.Auth)
    |> send_resp()
  end

  post "/api/user" do
    conn
    |> resp_actor(String.to_atom(conn |> get_req_header("x-auth-token") |> Enum.at(0)), true)
    |> send_resp()
  end

  post "/api/process" do
    conn
    |> resp_actor(App.Process)
    |> send_resp()
  end

  match _ do
    conn
    |> resp(404, "Not found")
    |> send_resp()
  end

  # FIXME: helper function, move out -ak
  defp to_keyword_list(map) do
    Enum.map(map, fn {k, v} -> {String.to_atom(k), v} end)
  end

  # FIXME: helper function, move out -ak
  defp parse_req_msg(conn) do
    # NOTE: a little strange... -ak
    req_msg =
      List.first(Map.to_list(conn.body_params))
    # NOTE: tuples kind of suck to concat together, so we've
    # chosen to make everything a list -ak
    IO.inspect(req_msg)
    case req_msg do
      {msg, msg_opts} when msg_opts == %{} ->
        {:ok, [String.to_atom(msg), []]}
      {msg, msg_opts} when is_bitstring(msg) and is_map(msg_opts) ->
        {:ok, [String.to_atom(msg), [Map.new(to_keyword_list(msg_opts))]]}
      _ ->
        {:error, :bad_req_msg}
    end
  end

  defp build_proxy_call(conn, need_auth?) do
    fn (actor, msg, msg_opts) ->
      IO.inspect(msg_opts)
      try do
        if need_auth? do
          with sid when not is_nil(sid) <- conn |> get_req_header("x-auth-token") |> Enum.at(0) do
            GenServer.call(String.to_atom(sid), [:proxy, actor, msg | msg_opts])
          else
            _ -> {:error, :bad_auth}
          end
        else
          GenServer.call(actor, [msg | msg_opts])
        end
      catch
        _, e ->
          {:error, :bad_actor}
      end
    end
  end

  defp resp_actor(conn, actor), do: resp_actor(conn, actor, false)
  defp resp_actor(conn, actor, need_auth?) when is_boolean(need_auth?) do
    with(
      {:ok, [msg, msg_opts]}
        <- parse_req_msg(conn),
      {:ok, reply}
        <- build_proxy_call(conn, need_auth?).(actor, msg, msg_opts))
    do
     conn
     |> put_resp_content_type("application/json")
     |> resp_j(200, reply)
    else
      {:error, :bad_req_msg} ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(500, "bad payload format")
      {:error, :bad_actor} ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(500, "internal actor error")
      e ->
        IO.inspect(e)
        conn
        |> put_resp_content_type("application/json")
        |> resp(500, "something very wrong has happened")
    end
  end

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
end


# defmodule AppWeb.Router do
#   use AppWeb, :route

#   plug :auth



#   require Logger

#   post "/api/users/:sid" do
#     addr = String.to_atom(sid)

#     conn
#     |> put_resp_content_type("application/json")
#     |> put_resp_actor(addr)
#   end

#   post "/api/auth" do
#     addr = App.Auth

#     conn
#     |> put_resp_content_type("application/json")
#     |> put_resp_actor(addr)
#   end

#   match _ do
#     conn
#     |> put_resp_content_type("application/json")
#     |> send_resp_j(404, {:error, :not_found})
#   end

#   defp put_resp_actor(conn, addr) do

#   end




#   defp forward_actor_resp_j(conn, addr) do
#     {msg_code, msg_reply} =
#       eval_payload(addr, conn.body_params)
#     send_resp_j(conn, msg_code, msg_reply)

#     conn
#   end



#   defp read_payload!(payload) do
#     case List.first(Map.to_list(payload)) do
#       {msg, %{}} when is_bitstring(msg) ->
#         String.to_atom(msg)
#       {msg, msg_opts} when is_bitstring(msg) and is_map(msg_opts) ->
#         {String.to_atom(msg), to_keyword_list(msg_opts)}
#       _ ->
#         raise "bad payload format, your payload should look something like this (e.g. for \"/api/auth\"):
#                {\"sign_in\":
#                  {\"username\": \"xxx\",
#                   \"password\": \"xxx\"
#                  }
#                }"
#     end
#   end

#   defp eval_payload(addr, payload) do
#     try do
#       case GenServer.call(addr, read_payload!(payload)) do
#         {:ok, reply} ->
#           {200, {:ok, reply}}
#         {:error, reply} ->
#           Logger.error(reply)
#           {500, :error}
#         reply ->
#           {200, {:ok, reply}}
#       end
#     catch
#       _kind, e -> {500, :error}
#     end
#   end


# end
