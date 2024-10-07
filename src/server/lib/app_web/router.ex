defmodule AppWeb.Router do
  use AppWeb, :route
  require Logger

  post "/api/users/:uid" do
    conn
    |> put_resp_content_type("application/json")
    |> forward_actor_resp_j(String.to_atom(uid))
  end

  post "/api/auth" do
    conn
    |> put_resp_content_type("application/json")
    |> forward_actor_resp_j(App.Auth)
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp_j(404, {:error, :not_found})
  end

  defp forward_actor_resp_j(conn, addr) do
    {msg_code, msg_reply} =
      eval_payload(addr, conn.body_params)
    send_resp_j(conn, msg_code, msg_reply)

    conn
  end

  defp to_keyword_list(map) do
    Enum.map(map, fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp read_payload!(payload) do
    case List.first(Map.to_list(payload)) do
      {msg, %{}} when is_bitstring(msg) ->
        String.to_atom(msg)
      {msg, msg_opts} when is_bitstring(msg) and is_map(msg_opts) ->
        {String.to_atom(msg), to_keyword_list(msg_opts)}
      _ ->
        raise "bad payload format, your payload should look something like this (e.g. for \"/api/auth\"):
               {\"sign_in\":
                 {\"username\": \"xxx\",
                  \"password\": \"xxx\"
                 }
               }"
    end
  end

  defp eval_payload(addr, payload) do
    try do
      case GenServer.call(addr, read_payload!(payload)) do
        {:ok, reply} ->
          {200, {:ok, reply}}
        {:error, reply} ->
          Logger.error(reply)
          {500, :error}
        reply ->
          {200, {:ok, reply}}
      end
    catch
      _kind, e -> {500, :error}
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

  defp send_resp_j(conn, http_code, unencoded) do
    try do
      send_resp(conn, http_code, Jason.encode!(unencoded))
    rescue
      e ->
        send_resp(conn, 500, Jason.encode!({:error, Exception.message(e)}))
        reraise e, __STACKTRACE__
    end
  end
end
