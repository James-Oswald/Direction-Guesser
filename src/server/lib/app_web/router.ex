defmodule AppWeb.Router do
  use AppWeb, :route

  match _ do
    send_resp(conn, 404, "Not found!")
  end
end
